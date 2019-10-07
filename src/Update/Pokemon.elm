module Update.Pokemon
    exposing
        ( updateOnLoadPokedex
        , updateSearchPokemon
        , updateChangeGenerationAndLetter
        , updateChangeVariant
        )

import RemoteData exposing (WebData, RemoteData(..))
import List.Extra exposing (unique, notMember)
import Navigation exposing (modifyUrl)
import Constants exposing (..)
import Models exposing (..)
import Models.Types exposing (..)
import Models.Pokemon exposing (..)
import Routing exposing (createBrowsePath)
import Msgs exposing (Msg)
import Ports exposing (preloadImages)
import Helpers
    exposing
        ( setStatusMessage
        , clearStatusMessage
        , clearWarningMessage
        )


-- some helper functions specific to update


filterCurrentSubpage : Int -> Char -> List PreloadCandidate -> List PreloadCandidate
filterCurrentSubpage gen letter imgList =
    List.filter (\i -> i.generation == gen || i.letter == letter) imgList


filterNotAlreadyPreloaded : PreloadedSets -> Int -> Char -> List PreloadCandidate -> List PreloadCandidate
filterNotAlreadyPreloaded preloaded gen letter imgList =
    List.filter
        (\i ->
            notMember i.generation preloaded.generations
                && notMember i.letter preloaded.letters
        )
        imgList


putCurrentGenFirst : Int -> List PreloadCandidate -> List PreloadCandidate
putCurrentGenFirst gen imgList =
    let
        ( head, tail ) =
            List.partition (.generation >> (>) gen) imgList
    in
        tail ++ head


mapCharLettersToString : List PreloadCandidate -> List PortCompatiblePreloadCandidate
mapCharLettersToString imgList =
    List.map (\i -> { i | letter = toString i.letter }) imgList


getPreloadCommandForPokedexCrossSection : PreloadedSets -> Int -> Char -> RemotePokedex -> Cmd msg
getPreloadCommandForPokedexCrossSection preloaded generation letter pokedex =
    let
        generationLetterAndImageUrl pokemon =
            List.map
                (\variant ->
                    { generation = pokemon.generation
                    , letter = pokemon.letter
                    , imageUrl = variant.image
                    }
                )
                pokemon.variants
    in
        case pokedex of
            Success actualPokedex ->
                actualPokedex
                    |> List.map generationLetterAndImageUrl
                    |> List.concat
                    |> filterCurrentSubpage generation letter
                    |> filterNotAlreadyPreloaded preloaded generation letter
                    |> putCurrentGenFirst generation
                    |> mapCharLettersToString
                    |> preloadImages

            _ ->
                Cmd.none


addCurrentSubpageToPreloaded : PreloadedSets -> Int -> Char -> PreloadedSets
addCurrentSubpageToPreloaded preloaded generation letter =
    let
        newGenerations =
            generation :: preloaded.generations

        newLetters =
            letter :: preloaded.letters
    in
        { preloaded
            | generations = unique newGenerations
            , letters = unique newLetters
        }



-- some update functions


updateOnLoadPokedex : ApplicationState -> RemotePokedex -> ( ApplicationState, Cmd Msg )
updateOnLoadPokedex oldState pokedex =
    let
        updateStatusMessage =
            case pokedex of
                NotAsked ->
                    setStatusMessage Notice "Preparing..."

                Loading ->
                    setStatusMessage Notice "Loading..."

                Failure mess ->
                    setStatusMessage Error (toString mess)

                Success _ ->
                    (\x -> x)

        command =
            getPreloadCommandForPokedexCrossSection
                oldState.preloaded
                oldState.generation
                oldState.letter
                pokedex

        newPreloaded =
            addCurrentSubpageToPreloaded
                oldState.preloaded
                oldState.generation
                oldState.letter

        newState =
            { oldState
                | pokedex = pokedex
                , preloaded = newPreloaded
            }
    in
        ( newState, command )
            |> updateStatusMessage


updateSearchPokemon : ApplicationState -> String -> ( ApplicationState, Cmd Msg )
updateSearchPokemon oldState query =
    let
        newSubpage =
            { generation = oldState.generation
            , letter = oldState.letter
            }

        newRoute =
            if query == "" then
                Browse WithoutMask newSubpage
            else
                Search query

        newCmd =
            if query == "" then
                createBrowsePath newSubpage.generation newSubpage.letter
                    |> modifyUrl
            else
                Cmd.none

        newState =
            { oldState | query = query, currentRoute = newRoute }
    in
        ( newState, newCmd )
            |> clearWarningMessage


updateChangeGenerationAndLetter : ApplicationState -> Route -> ( ApplicationState, Cmd Msg )
updateChangeGenerationAndLetter oldState newRoute =
    let
        ( newGen, newLetter ) =
            case newRoute of
                Default ->
                    ( oldState.generation, oldState.letter )

                Search _ ->
                    ( oldState.generation, oldState.letter )

                Browse _ newSubpage ->
                    ( newSubpage.generation, newSubpage.letter )

        command =
            getPreloadCommandForPokedexCrossSection
                oldState.preloaded
                newGen
                newLetter
                oldState.pokedex

        newPreloaded =
            case oldState.pokedex of
                Success _ ->
                    addCurrentSubpageToPreloaded
                        oldState.preloaded
                        newGen
                        newLetter

                _ ->
                    -- if the pokedex has not been loaded yet.
                    -- don't mark anything as 'already preloaded'
                    oldState.preloaded

        newBrowseRoute =
            { generation = newGen
            , letter = newLetter
            }
    in
        if
            List.member newGen allGenerations
                && List.member newLetter allLetters
        then
            ( { oldState
                | generation = newGen
                , letter = newLetter
                , preloaded = newPreloaded
                , currentRoute = newRoute
              }
            , command
            )
                |> clearWarningMessage
        else
            ( oldState, command )


updateChangeVariant : ApplicationState -> Int -> BrowseDirection -> ( ApplicationState, Cmd Msg )
updateChangeVariant oldState pokemonNumber direction =
    let
        newState =
            case oldState.pokedex of
                Success pokedex ->
                    let
                        maybePokemon =
                            List.filter (.number >> (==) pokemonNumber) pokedex
                                |> List.head
                    in
                        case maybePokemon of
                            Nothing ->
                                oldState

                            Just pokemon ->
                                let
                                    proposedNewVariant =
                                        if direction == Next then
                                            pokemon.currentVariant + 1
                                        else
                                            pokemon.currentVariant - 1

                                    newVariant =
                                        if proposedNewVariant < 1 then
                                            List.length pokemon.variants
                                        else if proposedNewVariant > List.length pokemon.variants then
                                            1
                                        else
                                            proposedNewVariant

                                    newPokemon =
                                        { pokemon | currentVariant = newVariant }

                                    newPokedex =
                                        List.map
                                            (\p ->
                                                if p.number == pokemonNumber then
                                                    newPokemon
                                                else
                                                    p
                                            )
                                            pokedex
                                in
                                    { oldState | pokedex = RemoteData.succeed newPokedex }

                _ ->
                    oldState
    in
        ( newState, Cmd.none )
