module Update.Ratings exposing (updateVoteForPokemon)

import Task
import Time exposing (now)
import Set exposing (Set)
import String.Extra exposing (replaceSlice)
import Maybe.Extra exposing (unwrap)
import RemoteData exposing (WebData, RemoteData(..))
import Constants exposing (..)
import Models exposing (..)
import Models.Types exposing (..)
import Models.Ratings exposing (..)
import Msgs exposing (Msg(..))
import Helpers exposing (setStatusMessage, clearStatusMessage)
import Helpers.Pokemon
    exposing
        ( filterPokedex
        , extractOneUserFromRatings
        , extractOnePokemonFromRatingString
        )
import Commands.Ratings exposing (saveRatings)


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
            ++ if lengthDifference <= 0 then
                ""
               else
                String.repeat lengthDifference "0"


isValidVote : Int -> Set Int -> Bool
isValidVote newPokeRating otherPokemonRatings =
    newPokeRating == 0 || not (Set.member newPokeRating otherPokemonRatings)


registerVote : ApplicationState -> TeamRatings -> TeamRatings -> String -> Int -> Int -> Int -> ( ApplicationState, Cmd Msg )
registerVote oldState otherUsersRatings oldCurrentUserRatings oldUserRatingString totalPokemon pokemonNumber newPokeRating =
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
                            pokemonNumber
                            (pokemonNumber + 1)
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
    let
        totalPokemon =
            oldState.pokedex
                |> RemoteData.map List.length
                |> RemoteData.withDefault 0
    in
        oldState.ratings
            |> RemoteData.toMaybe
            |> Maybe.Extra.unwrap
                -- default value (no ratings)
                ( oldState, Cmd.none )
                -- map function
                (\oldRatings ->
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
                                |> ensureRatingStringLength totalPokemon

                        -- CHECK IF VOTE HAS NOT ALREADY BEEN CAST
                        ( newState, newCmd ) =
                            oldState.pokedex
                                |> RemoteData.toMaybe
                                |> Maybe.Extra.unwrap
                                    -- default value (no pokedex)
                                    ( oldState, Cmd.none )
                                    -- map function
                                    (\actualPokedex ->
                                        -- find pokemon category (generation and letter):
                                        let
                                            ( generation, letter ) =
                                                case oldState.currentRoute of
                                                    -- TODO don't support voting in search mode!
                                                    Search _ ->
                                                        List.filter (.number >> (==) pokemonNumber) actualPokedex
                                                            |> List.map (\p -> ( p.generation, p.letter ))
                                                            |> List.head
                                                            |> Maybe.withDefault ( 0, '?' )

                                                    _ ->
                                                        -- currentRoute == any browse mode
                                                        ( oldState.generation, oldState.letter )

                                            -- extract one pokemon rating
                                            oldPokeRating =
                                                extractOnePokemonFromRatingString oldUserRatingString pokemonNumber

                                            -- fetch the new vote. If it is the same as old vote, then 'unvote' this pokemon.
                                            newPokeRating =
                                                if oldPokeRating == userVote.vote then
                                                    0
                                                else
                                                    userVote.vote

                                            pokeList =
                                                filterPokedex oldState.pokedex generation letter

                                            otherPokemonRatings =
                                                pokeList
                                                    |> List.map (.number >> extractOnePokemonFromRatingString oldUserRatingString)
                                                    |> Set.fromList
                                        in
                                            if isValidVote newPokeRating otherPokemonRatings then
                                                -- register new vote
                                                registerVote
                                                    oldState
                                                    otherUsersRatings
                                                    oldCurrentUserRatings
                                                    oldUserRatingString
                                                    totalPokemon
                                                    pokemonNumber
                                                    newPokeRating
                                            else
                                                -- vote already cast
                                                ( oldState, Cmd.none )
                                                    |> setStatusMessage Warning
                                                        ("You already voted " ++ toString newPokeRating ++ " in this category")
                                    )
                    in
                        ( newState, newCmd )
                )
