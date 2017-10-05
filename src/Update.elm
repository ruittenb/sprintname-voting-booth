module Update exposing (update)

import Array
import RemoteData exposing (..)
import Constants exposing (..)
import Models exposing (..)
import Helpers exposing (generationOf)
import Msgs exposing (Msg)
import CommandsPokemon exposing (loadPokemon, loadGeneration)


-- import CommandsRatings exposing (..)


extractOneUserFromRatings : TeamRatings -> CurrentUser -> List UserRatings
extractOneUserFromRatings ratings currentUser =
    case currentUser of
        Nothing ->
            []

        Just simpleUserName ->
            List.filter (\p -> (==) simpleUserName p.userName) ratings


extractOtherUsersFromRatings : TeamRatings -> CurrentUser -> List UserRatings
extractOtherUsersFromRatings ratings currentUser =
    case currentUser of
        Nothing ->
            ratings

        Just simpleUserName ->
            List.filter (\p -> (/=) simpleUserName p.userName) ratings


getGenerationStart : Int -> Maybe Int
getGenerationStart gen =
    Array.get gen generations
        |> Maybe.map Tuple.first


getGenerationEnd : Int -> Maybe Int
getGenerationEnd gen =
    Array.get gen generations
        |> Maybe.map Tuple.second


update : Msg -> ApplicationState -> ( ApplicationState, Cmd Msg )
update msg oldState =
    case msg of
        Msgs.OnLoadRatings ratings ->
            let
                ( statusMessage, statusLevel ) =
                    case ratings of
                        NotAsked ->
                            ( "Preparing...", Notice )

                        Loading ->
                            ( "Loading...", Notice )

                        Success _ ->
                            ( "", None )

                        Failure mess ->
                            ( toString mess, Error )

                firstPokemonLoadCmd =
                    case getGenerationStart oldState.generation of
                        Just nextNumber ->
                            loadPokemon nextNumber

                        Nothing ->
                            Cmd.none

                newState =
                    { oldState
                        | statusMessage = statusMessage
                        , statusLevel = statusLevel
                        , ratings = ratings
                    }
            in
                ( newState, firstPokemonLoadCmd )

        Msgs.OnLoadPokemon ( num, loadedPokemon ) ->
            let
                gen : Int
                gen =
                    generationOf num

                oldPokedex =
                    oldState.pokedex

                newPokedex =
                    Array.set num loadedPokemon oldState.pokedex

                ( statusMessage, statusLevel ) =
                    case loadedPokemon of
                        NotAsked ->
                            ( "Preparing...", Notice )

                        Loading ->
                            ( "Loading...", Notice )

                        Failure mess ->
                            ( toString mess, Error )

                        _ ->
                            ( "", None )

                nextPokemonLoadCmd =
                    case getGenerationEnd (generationOf num) of
                        Just endNumber ->
                            if num <= endNumber then
                                loadPokemon (num + 1)
                            else
                                Cmd.none

                        Nothing ->
                            Cmd.none

                newState =
                    { oldState
                        | pokedex = newPokedex
                        , statusMessage = statusMessage
                        , statusLevel = statusLevel
                    }
            in
                ( newState, nextPokemonLoadCmd )

        Msgs.ChangeUser newUser ->
            let
                newState =
                    case oldState.ratings of
                        RemoteData.Success actualRatings ->
                            if
                                List.map .userName actualRatings
                                    |> List.member newUser
                            then
                                { oldState | user = Just newUser }
                            else
                                oldState

                        _ ->
                            oldState
            in
                ( newState, Cmd.none )

        Msgs.ChangeGeneration newGen ->
            let
                ( newState, cmd ) =
                    if List.member newGen allGenerations then
                        let
                            newState =
                                { oldState | generation = newGen }

                            firstPokemonLoadCmd =
                                case getGenerationStart newGen of
                                    Just nextNumber ->
                                        loadPokemon nextNumber

                                    Nothing ->
                                        Cmd.none
                        in
                            ( newState, firstPokemonLoadCmd )
                    else
                        ( oldState, Cmd.none )
            in
                ( newState, cmd )

        Msgs.ChangeLetter newLetter ->
            let
                newState =
                    { oldState | letter = newLetter }
            in
                if List.member newLetter allLetters then
                    ( newState, Cmd.none )
                else
                    ( oldState, Cmd.none )

        Msgs.VoteForPokemon userVote ->
            case oldState.ratings of
                NotAsked ->
                    ( oldState, Cmd.none )

                Loading ->
                    ( oldState, Cmd.none )

                Failure _ ->
                    ( oldState, Cmd.none )

                Success oldRatings ->
                    let
                        pokemonNumber =
                            userVote.pokemonNumber

                        -- extract one user
                        oldCurrentUserRatings =
                            extractOneUserFromRatings oldRatings oldState.user
                                |> List.head

                        -- the list of the other users
                        otherUserRatings =
                            extractOtherUsersFromRatings oldRatings oldState.user

                        -- extract user rating string, or create one
                        oldUserRatingString =
                            case oldCurrentUserRatings of
                                Nothing ->
                                    String.repeat totalPokemon "0"

                                Just actualUserRatings ->
                                    actualUserRatings.ratings

                        -- extract one pokemon rating
                        oldPokeRating =
                            String.slice pokemonNumber (pokemonNumber + 1) oldUserRatingString
                                |> String.toInt
                                |> Result.withDefault 0

                        -- find new vote. If the same as old vote, clear it
                        newPokeRating =
                            if oldPokeRating == userVote.vote then
                                0
                            else
                                userVote.vote

                        -- store new vote in rating string
                        newUserRatingString =
                            (String.slice 0 pokemonNumber oldUserRatingString)
                                ++ (toString newPokeRating)
                                ++ (String.slice (pokemonNumber + 1) (totalPokemon + 1) oldUserRatingString)

                        -- insert into new state
                        newState =
                            case oldCurrentUserRatings of
                                Nothing ->
                                    oldState

                                Just actualUserRatings ->
                                    let
                                        newCurrentUserRatings =
                                            { actualUserRatings | ratings = newUserRatingString }

                                        newStateRatings =
                                            newCurrentUserRatings :: otherUserRatings
                                    in
                                        { oldState | ratings = RemoteData.Success newStateRatings, statusMessage = "" }
                    in
                        ( newState, Cmd.none )



{-
   ( newState, saveRatings newStateRatings )
-}
