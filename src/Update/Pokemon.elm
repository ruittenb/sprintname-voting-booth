module Update.Pokemon
    exposing
        ( updateOnLoadPokedex
        , updateSearchPokemon
        , updateChangeGenerationAndLetter
        , updateChangeVariant
        )

import RemoteData exposing (WebData, RemoteData(..))
import List.Extra exposing (unique, notMember)
import Constants exposing (..)
import Models exposing (..)
import Models.Types exposing (..)
import Models.Pokemon exposing (..)
import Msgs exposing (Msg)
import Ports exposing (preloadImages)


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
        generationLetterAndImageUrl p =
            List.map
                (\v ->
                    { generation = p.generation
                    , letter = p.letter
                    , imageUrl = v.image
                    }
                )
                p.variants
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
        ( statusMessage, statusLevel ) =
            case pokedex of
                NotAsked ->
                    ( "Preparing...", Notice )

                Loading ->
                    ( "Loading...", Notice )

                Failure mess ->
                    ( toString mess, Error )

                Success _ ->
                    ( "", None )

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
                , statusMessage = statusMessage
                , statusLevel = statusLevel
                , preloaded = newPreloaded
            }
    in
        ( newState, command )


updateSearchPokemon : ApplicationState -> String -> ( ApplicationState, Cmd Msg )
updateSearchPokemon oldState query =
    let
        newBrowseRoute =
            { generation = oldState.generation
            , letter = oldState.letter
            }

        newRoute =
            if query == "" then
                Browse newBrowseRoute
            else
                Search query

        newState =
            { oldState | query = query, currentRoute = newRoute }
    in
        ( newState, Cmd.none )


updateChangeGenerationAndLetter : ApplicationState -> Int -> Char -> ( ApplicationState, Cmd Msg )
updateChangeGenerationAndLetter oldState newGen newLetter =
    let
        command =
            getPreloadCommandForPokedexCrossSection
                oldState.preloaded
                newGen
                newLetter
                oldState.pokedex

        newPreloaded =
            addCurrentSubpageToPreloaded
                oldState.preloaded
                newGen
                newLetter

        newBrowseRoute =
            { generation = newGen
            , letter = newLetter
            }

        newState =
            if
                List.member newGen allGenerations
                    && List.member newLetter allLetters
            then
                { oldState
                    | generation = newGen
                    , letter = newLetter
                    , preloaded = newPreloaded
                    , statusMessage = ""
                    , statusLevel = None
                    , currentRoute = Browse newBrowseRoute
                }
            else
                oldState
    in
        ( newState, command )


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
