module View.Calculations exposing (calculatePeopleVotes, calculatePokemonVotes)

import RemoteData exposing (WebData, RemoteData(..))
import Models exposing (..)
import Models.Ratings exposing (..)
import Models.Pokemon exposing (..)
import Helpers
    exposing
        ( filterPokedex
        , extractOnePokemonFromRatingString
        )


addOneUserVoteByUser : UserRatings -> Pokemon -> Int -> Int
addOneUserVoteByUser userRatings pokemon total =
    total + extractOnePokemonFromRatingString userRatings.ratings pokemon.number


sumVotesByUser : List Pokemon -> UserRatings -> TeamGenLetterVotes -> TeamGenLetterVotes
sumVotesByUser pokelist userRatings teamGenLetterVotes =
    let
        totalVotes =
            List.foldl (addOneUserVoteByUser userRatings) 0 pokelist

        expectedVotes =
            if List.length pokelist == 0 then
                0
            else if List.length pokelist == 1 then
                3
            else if List.length pokelist == 2 then
                5
            else
                6

        completionLevel =
            if totalVotes == expectedVotes then
                Complete
            else if totalVotes == 0 then
                Absent
            else
                Incomplete
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



{-
   sumVotesByUser : List Pokemon -> UserRatings -> TeamGenLetterVotes -> TeamGenLetterVotes
   sumVotesByUser pokelist userRatings teamGenLetterVotes =
       let
           totalVotes =
               List.foldl (addOneUserVoteByUser userRatings) 0 pokelist

           teamGenLetterVote =
               if userRatings.active && totalVotes > 0 then
                   [ { userName = userRatings.userName
                     , totalVotes = totalVotes
                     }
                   ]
               else
                   []
       in
           teamGenLetterVote ++ teamGenLetterVotes
-}


calculatePeopleVotes : ApplicationState -> TeamGenLetterVotes
calculatePeopleVotes model =
    let
        pokelist =
            filterPokedex
                model.pokedex
                model.generation
                model.letter

        teamRatings =
            case model.ratings of
                Success teamRatings ->
                    teamRatings

                _ ->
                    []
    in
        List.foldl (sumVotesByUser pokelist) [] teamRatings



{-
   Calculates the number of total votes (for the current generation and letter) by user.
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
        pokelist =
            filterPokedex
                model.pokedex
                model.generation
                model.letter

        teamRatings =
            case model.ratings of
                Success teamRatings ->
                    teamRatings

                _ ->
                    []
    in
        List.foldl (sumVotesByPokemon teamRatings) [] pokelist
