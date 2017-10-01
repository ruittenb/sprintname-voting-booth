module Update exposing (..)

import Constants exposing (..)
import Models exposing (..)
import Msgs exposing (Msg)
import CommandsRatings exposing (saveVotes)


extractOneUserFromRatings : List UserRatings -> CurrentUserName -> List UserRatings
extractOneUserFromRatings ratings currentUser =
    case currentUser of
        Nothing ->
            []

        Just simpleUserName ->
            List.filter (\p -> (==) simpleUserName p.userName) ratings


extractOtherUsersFromRatings : List UserRatings -> CurrentUserName -> List UserRatings
extractOtherUsersFromRatings ratings currentUser =
    case currentUser of
        Nothing ->
            ratings

        Just simpleUserName ->
            List.filter (\p -> (/=) simpleUserName p.userName) ratings


update : Msg -> ApplicationState -> ( ApplicationState, Cmd Msg )
update msg oldState =
    case msg of
        Msgs.ChangeGeneration newGen ->
            let
                newState =
                    { oldState | generation = newGen }
            in
                if List.member newGen allGenerations then
                    ( newState, Cmd.none )
                else
                    ( oldState, Cmd.none )

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
            let
                pokemonNumber =
                    userVote.pokemonNumber

                -- extract one user
                oldCurrentUserRatings =
                    extractOneUserFromRatings oldState.ratings oldState.user
                        |> List.head

                -- the list of the other users
                otherUserRatings =
                    extractOtherUsersFromRatings oldState.ratings oldState.user

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
                                { oldState | ratings = newStateRatings, statusMessage = "" }
            in
                ( newState, saveRatings newStateRatings )

        Msgs.OnLoadRatings (Ok ratings) ->
            ( { oldState | ratings = ratings, statusMessage = "" }, Cmd.none )

        Msgs.OnLoadRatings (Err httpError) ->
            ( { oldState | statusMessage = toString httpError, statusLevel = Error }, Cmd.none )

        -- TODO
        Msgs.OnLoadPokemon pokemon ->
            ( oldState, Cmd.none )
