module Update.Pokemon
    exposing
        ( updateOnLoadPokedex
        , updateSearchPokemon
        , updateChangeGenerationAndLetter
        , updateChangeVariant
        )

import RemoteData exposing (WebData, RemoteData(..))
import List.Extra exposing (unique, notMember)
import Maybe.Extra exposing (unwrap)
import Navigation exposing (modifyUrl)
import Constants exposing (..)
import Models exposing (..)
import Models.Types exposing (..)
import Models.Pokemon exposing (..)
import Routing exposing (createBrowseFreelyPath)
import Msgs exposing (Msg)
import Ports exposing (preloadImages)
import Helpers
    exposing
        ( setStatusMessage
        , clearStatusMessage
        , clearWarningMessage
        )


-- some helper functions specific to update


remoteDataUnwrap : b -> (a -> b) -> RemoteData e a -> b
remoteDataUnwrap defaultValue mapFunction =
    RemoteData.map mapFunction >> RemoteData.withDefault defaultValue


filterCurrentSubpage : String -> Char -> List PreloadCandidate -> List PreloadCandidate
filterCurrentSubpage gen letter imgList =
    List.filter (\i -> i.generation == gen && i.letter == letter) imgList


mapCharLettersToString : List PreloadCandidate -> List PortCompatiblePreloadCandidate
mapCharLettersToString imgList =
    List.map (\i -> { i | letter = String.fromChar i.letter }) imgList


getPreloadCommandForPokedexCrossSection : String -> Char -> RemotePokedex -> Cmd msg
getPreloadCommandForPokedexCrossSection generation letter pokedex =
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
                    |> mapCharLettersToString
                    |> preloadImages

            _ ->
                Cmd.none



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
            oldState.subPage
                |> Maybe.map
                    (\subPage ->
                        getPreloadCommandForPokedexCrossSection
                            subPage.generation
                            subPage.letter
                            pokedex
                    )
                |> Maybe.withDefault Cmd.none

        newState =
            { oldState | pokedex = pokedex }
    in
        ( newState, command )
            |> updateStatusMessage


updateSearchPokemon : ApplicationState -> SearchMode -> String -> ( ApplicationState, Cmd Msg )
updateSearchPokemon oldState newSearchMode query =
    let
        newSubPage =
            oldState.subPage

        newRoute =
            if query == "" then
                newSubPage
                    |> Maybe.map (Browse BFreely)
                    |> Maybe.withDefault Default
            else
                Search newSearchMode query

        newCmd =
            if query == "" then
                newSubPage
                    |> Maybe.map
                        (\actualSubPage ->
                            createBrowseFreelyPath actualSubPage.generation actualSubPage.letter
                                |> modifyUrl
                        )
                    |> Maybe.withDefault Cmd.none
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
        newSubPage =
            case newRoute of
                Browse _ newRouteSubPage ->
                    Just { generation = newRouteSubPage.generation, letter = newRouteSubPage.letter }

                _ ->
                    oldState.subPage

        isNewPageValid =
            newSubPage
                |> Maybe.map
                    (\subPage ->
                        List.member subPage.generation allGenerations
                            && List.member subPage.letter allLetters
                    )
                |> Maybe.withDefault False

        command =
            newSubPage
                |> Maybe.map
                    (\subPage ->
                        getPreloadCommandForPokedexCrossSection
                            subPage.generation
                            subPage.letter
                            oldState.pokedex
                    )
                |> Maybe.withDefault Cmd.none
    in
        if isNewPageValid then
            ( { oldState
                | subPage = newSubPage
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
            oldState.pokedex
                |> remoteDataUnwrap
                    -- defaultValue
                    oldState
                    -- mapFunction
                    (\pokedex ->
                        List.filter (.number >> (==) pokemonNumber) pokedex
                            |> List.head
                            |> Maybe.Extra.unwrap
                                -- defaultValue
                                oldState
                                -- mapFunction
                                (\pokemon ->
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
                                )
                    )
    in
        ( newState, Cmd.none )
