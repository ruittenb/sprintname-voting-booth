module Update.Ratings exposing (updateVoteForPokemon)

import Set
import Task
import Time exposing (now)
import RemoteData exposing (WebData, RemoteData(..))
import Constants exposing (..)
import Models exposing (..)
import Models.Types exposing (..)
import Models.Ratings exposing (..)
import Msgs exposing (Msg(..))
import Helpers exposing (setStatusMessage)
import Helpers.Pokemon
    exposing
        ( filterPokedex
        , extractOneUserFromRatings
        , extractOnePokemonFromRatingString
        )
import Commands.Ratings exposing (saveRatings)


{-
   See if the ratings string is long enough to accommodate all pokemon.
   If not, expand it.
-}


ensureRatingStringLength : String -> String
ensureRatingStringLength ratingString =
    let
        lengthDifference =
            totalPokemon - String.length ratingString
    in
        ratingString
            ++ if lengthDifference <= 0 then
                ""
               else
                String.repeat lengthDifference "0"


updateVoteForPokemon : ApplicationState -> UserVote -> ( ApplicationState, Cmd Msg )
updateVoteForPokemon oldState userVote =
    case oldState.ratings of
        Success oldRatings ->
            let
                -- GET THE REQUIRED DATA
                pokemonNumber =
                    userVote.pokemonNumber

                -- extract one user
                ( oldCurrentUserRatings, otherUsersRatings ) =
                    extractOneUserFromRatings oldRatings oldState.currentUser

                -- extract user rating string, or create one
                oldUserRatingString =
                    List.head oldCurrentUserRatings
                        |> Maybe.map .ratings
                        |> Maybe.withDefault ""
                        |> ensureRatingStringLength

                -- CHECK IF VOTE HAS NOT ALREADY BEEN CAST
                ( newState, newCmd ) =
                    case oldState.pokedex of
                        Success actualPokedex ->
                            -- find pokemon category (generation and letter):
                            let
                                ( generation, letter ) =
                                    case oldState.currentRoute of
                                        Search _ ->
                                            List.filter (.number >> (==) pokemonNumber) actualPokedex
                                                |> List.map (\p -> ( p.generation, p.letter ))
                                                |> List.head
                                                |> Maybe.withDefault ( 0, '?' )

                                        _ ->
                                            -- currentRoute == browse*
                                            ( oldState.generation, oldState.letter )

                                pokeList =
                                    filterPokedex oldState.pokedex generation letter

                                -- extract one pokemon rating
                                oldPokeRating =
                                    extractOnePokemonFromRatingString oldUserRatingString pokemonNumber

                                -- find new vote. If the same as old vote, clear it
                                newPokeRating =
                                    if oldPokeRating == userVote.vote then
                                        0
                                    else
                                        userVote.vote

                                otherPokemonRatings =
                                    Set.fromList <|
                                        List.map (.number >> extractOnePokemonFromRatingString oldUserRatingString) pokeList
                            in
                                -- REGISTER NEW VOTE
                                if newPokeRating == 0 || not (Set.member newPokeRating otherPokemonRatings) then
                                    case List.head oldCurrentUserRatings of
                                        Nothing ->
                                            ( oldState, Cmd.none )

                                        Just actualUserRatings ->
                                            let
                                                -- store new vote in rating string
                                                newUserRatingString =
                                                    (String.slice 0 pokemonNumber oldUserRatingString)
                                                        ++ (toString newPokeRating)
                                                        ++ (String.slice (pokemonNumber + 1) (totalPokemon + 1) oldUserRatingString)

                                                -- insert into new state
                                                newCurrentUserRatings =
                                                    { actualUserRatings | ratings = newUserRatingString }

                                                newStateRatings =
                                                    newCurrentUserRatings :: otherUsersRatings
                                            in
                                                ( { oldState | ratings = Success newStateRatings }
                                                , saveRatings newCurrentUserRatings
                                                )
                                                    |> setStatusMessage None ""
                                else
                                    -- vote already cast
                                    ( oldState, Cmd.none )
                                        |> setStatusMessage Warning
                                            ("You already voted " ++ toString newPokeRating ++ " in this category")

                        _ ->
                            -- no pokedex
                            ( oldState, Cmd.none )
            in
                ( newState, newCmd )

        _ ->
            ( oldState, Cmd.none )
