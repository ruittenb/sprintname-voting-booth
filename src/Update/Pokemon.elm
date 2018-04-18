module Update.Pokemon
    exposing
        ( updateOnLoadPokedex
        , updateSearchPokemon
        , updateChangeGenerationAndLetter
        , updateChangeVariant
        )

import RemoteData exposing (WebData, RemoteData(..))
import Constants exposing (..)
import Models exposing (..)
import Models.Types exposing (..)
import Models.Pokemon exposing (..)
import Msgs exposing (Msg)
import Ports exposing (preloadImages)


-- some helper functions specific to update


putCurrentGenFirst : Int -> List PreloadCandidate -> List PreloadCandidate
putCurrentGenFirst gen imgList =
    let
        ( head, tail ) =
            List.partition (.generation >> (>) gen) imgList
    in
        tail ++ head



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

        newState =
            { oldState
                | pokedex = pokedex
                , statusMessage = statusMessage
                , statusLevel = statusLevel
            }

        generationAndImageUrl p =
            List.map
                (\v ->
                    { generation = p.generation
                    , imageUrl = v.image
                    }
                )
                p.variants

        command =
            case pokedex of
                Success actualPokedex ->
                    actualPokedex
                        |> List.map generationAndImageUrl
                        |> List.concat
                        |> putCurrentGenFirst oldState.generation
                        |> preloadImages

                _ ->
                    Cmd.none
    in
        ( newState, command )


updateSearchPokemon : ApplicationState -> String -> ( ApplicationState, Cmd Msg )
updateSearchPokemon oldState query =
    let
        newViewMode =
            if query == "" then
                Browse
            else
                Search

        newState =
            { oldState | query = query, viewMode = newViewMode }
    in
        ( newState, Cmd.none )


updateChangeGenerationAndLetter : ApplicationState -> Int -> Char -> ( ApplicationState, Cmd Msg )
updateChangeGenerationAndLetter oldState newGen newLetter =
    let
        newState =
            if
                List.member newGen allGenerations
                    && List.member newLetter allLetters
            then
                { oldState
                    | letter = newLetter
                    , generation = newGen
                    , statusMessage = ""
                    , statusLevel = None
                    , viewMode = Browse
                }
            else
                oldState
    in
        ( newState, Cmd.none )


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
