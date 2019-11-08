module View.Calculations exposing (calculatePeopleVotes, calculatePokemonVotes)

import RemoteData exposing (WebData, RemoteData(..))
import Constants exposing (maxStars)
import Models exposing (..)
import Models.Ratings exposing (..)
import Models.Pokemon exposing (..)
import Helpers.Pokemon
    exposing
        ( filterPokedex
        , extractOnePokemonFromRatingString
        )


{-
   Calculates the number of total votes (for the current generation and letter) by user.
   This helps to decide if everyone has cast the correct number of votes.
-}


addOneUserVoteByUser : UserRatings -> Pokemon -> Int -> Int
addOneUserVoteByUser userRatings pokemon total =
    total + extractOnePokemonFromRatingString userRatings.ratings pokemon.number


sumVotesByUser : List Pokemon -> Int -> UserRatings -> TeamGenLetterVotes -> TeamGenLetterVotes
sumVotesByUser pokeList expectedVotes userRatings teamGenLetterVotes =
    let
        totalVotes =
            List.foldl (addOneUserVoteByUser userRatings) 0 pokeList

        completionLevel =
            if totalVotes >= expectedVotes then
                Complete
            else if totalVotes > 0 then
                Incomplete
            else
                Absent
    in
        if userRatings.active || totalVotes > 0 then
            { userId = userRatings.id
            , userName = userRatings.userName
            , totalVotes = totalVotes
            , completionLevel = completionLevel
            }
                :: teamGenLetterVotes
        else
            teamGenLetterVotes


calculatePeopleVotes : ApplicationState -> TeamGenLetterVotes
calculatePeopleVotes model =
    let
        pokeList =
            filterPokedex
                model.pokedex
                model.subPage

        maxNrPokemonToReceiveVotes : Int
        maxNrPokemonToReceiveVotes =
            List.length pokeList
                |> clamp 0 maxStars

        minStarsOnThisPage : Int
        minStarsOnThisPage =
            maxStars - maxNrPokemonToReceiveVotes + 1

        expectedVotes : Int
        expectedVotes =
            List.range minStarsOnThisPage maxStars
                |> List.foldr (+) 0
    in
        model.ratings
            |> RemoteData.withDefault []
            |> List.foldl (sumVotesByUser pokeList expectedVotes) []



{-
   Calculates the number of total votes (for the current generation and letter) by pokemon.
   This helps to decide which pokemon won this round's votes.
-}


addOneUserVoteByPokemon : Int -> UserRatings -> Int -> Int
addOneUserVoteByPokemon pokeNumber userRatings total =
    total + extractOnePokemonFromRatingString userRatings.ratings pokeNumber


sumVotesByPokemon : TeamRatings -> Pokemon -> PokeRankings -> PokeRankings
sumVotesByPokemon teamRatings pokemon rankings =
    let
        totalVotes =
            List.foldl (addOneUserVoteByPokemon pokemon.number) 0 teamRatings

        ranking =
            { number = pokemon.number
            , name = pokemon.name
            , totalVotes = totalVotes
            }
    in
        ranking :: rankings


calculatePokemonVotes : ApplicationState -> PokeRankings
calculatePokemonVotes model =
    let
        pokeList =
            filterPokedex
                model.pokedex
                model.subPage

        teamRatings =
            case model.ratings of
                Success teamRatings ->
                    teamRatings

                _ ->
                    []
    in
        List.foldl (sumVotesByPokemon teamRatings) [] pokeList
