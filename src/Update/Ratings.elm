module Update.Ratings exposing (updateVoteForPokemon)

import Commands.Ratings exposing (saveRatings)
import Constants exposing (..)
import Helpers exposing (clearStatusMessage, setStatusMessage)
import Helpers.Pokemon
    exposing
        ( extractOnePokemonFromRatingString
        , extractOneUserFromRatings
        , filterPokedex
        )
import Maybe.Extra exposing (unwrap)
import Models exposing (..)
import Models.Ratings exposing (..)
import Models.Types exposing (..)
import Msgs exposing (Msg(..))
import RemoteData exposing (RemoteData(..), WebData)
import Set exposing (Set)
import String.Extra exposing (replaceSlice)



{-
   See if the ratings string is long enough to accommodate all pokemon in the pokedex.
   If not, expand it.
-}


ensureRatingStringLength : Int -> String -> String
ensureRatingStringLength totalPokemon ratingString =
    let
        lengthDifference =
            totalPokemon - String.length ratingString
    in
    ratingString
        ++ (if lengthDifference <= 0 then
                ""

            else
                String.repeat lengthDifference "0"
           )


isValidVote : Int -> Set Int -> Bool
isValidVote newPokeRating otherPokemonRatings =
    newPokeRating == 0 || not (Set.member newPokeRating otherPokemonRatings)


registerVote : ApplicationState -> TeamRatings -> TeamRatings -> String -> Int -> Int -> Int -> ( ApplicationState, Cmd Msg )
registerVote oldState otherUsersRatings oldCurrentUserRatings oldUserRatingString totalPokemon pokemonId newPokeRating =
    List.head oldCurrentUserRatings
        |> Maybe.Extra.unwrap
            -- default value
            ( oldState, Cmd.none )
            -- map function
            (\actualUserRatings ->
                let
                    -- store new vote in rating string
                    newUserRatingString =
                        replaceSlice
                            (toString newPokeRating)
                            pokemonId
                            (pokemonId + 1)
                            oldUserRatingString

                    -- insert into new state
                    newCurrentUserRatings =
                        { actualUserRatings | ratings = newUserRatingString }

                    newStateRatings =
                        newCurrentUserRatings :: otherUsersRatings
                in
                ( { oldState | ratings = Success newStateRatings }
                , saveRatings newCurrentUserRatings
                )
                    |> clearStatusMessage
            )


updateVoteForPokemon : ApplicationState -> UserVote -> ( ApplicationState, Cmd Msg )
updateVoteForPokemon oldState userVote =
    Maybe.map2
        (\oldRatings actualPokedex ->
            let
                -- find info about the user's vote
                pokemonId =
                    userVote.pokemonId

                -- find how many pokemon there are in the pokedex
                totalPokemon =
                    List.length actualPokedex

                -- extract one user
                ( oldCurrentUserRatings, otherUsersRatings ) =
                    extractOneUserFromRatings oldRatings oldState.currentUser

                -- extract user rating string, make sure it can hold all votes
                oldUserRatingString =
                    List.head oldCurrentUserRatings
                        |> Maybe.map .ratings
                        |> Maybe.withDefault ""
                        |> ensureRatingStringLength totalPokemon

                -- extract one pokemon rating
                oldPokeRating =
                    extractOnePokemonFromRatingString oldUserRatingString pokemonId

                -- fetch the new vote. If it is the same as old vote, then 'unvote' this pokemon.
                newPokeRating =
                    if oldPokeRating == userVote.vote then
                        0

                    else
                        userVote.vote

                -- find all the other pokemon on this page (generation and letter)
                otherPokemonList =
                    filterPokedex oldState.pokedex oldState.subPage

                -- find the ratings for these
                otherPokemonRatings =
                    otherPokemonList
                        |> List.map (.id >> extractOnePokemonFromRatingString oldUserRatingString)
                        |> Set.fromList

                ( newState, newCmd ) =
                    -- check if vote has not already been cast
                    if isValidVote newPokeRating otherPokemonRatings then
                        -- if not already cast, register new vote
                        registerVote
                            oldState
                            otherUsersRatings
                            oldCurrentUserRatings
                            oldUserRatingString
                            totalPokemon
                            pokemonId
                            newPokeRating

                    else
                        -- vote already cast: abort
                        ( oldState, Cmd.none )
                            |> setStatusMessage Warning
                                ("You already voted " ++ toString newPokeRating ++ " in this category")
            in
            ( newState, newCmd )
        )
        (RemoteData.toMaybe oldState.ratings)
        (RemoteData.toMaybe oldState.pokedex)
        |> Maybe.withDefault
            -- default value (if ratings or pokedex not loaded)
            ( oldState, Cmd.none )
