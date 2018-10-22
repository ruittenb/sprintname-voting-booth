module View.Calculations exposing (calculateVoters, calculateRankings)

import Html exposing (Html, div, text)
import RemoteData exposing (WebData, RemoteData(..))
import Models exposing (..)
import Models.Ratings exposing (..)
import Models.Pokemon exposing (..)
import Msgs exposing (Msg)
import Helpers
    exposing
        ( filterPokedex
        , extractOnePokemonFromRatingString
        )


calculateVoters : ApplicationState -> Html Msg
calculateVoters model =
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

        pokeVotes =
            List.foldl (addTeamVotes teamRatings) [] pokelist
    in
        div [] [ text "voters here" ]


addUserVote : Int -> UserRatings -> Int -> Int
addUserVote pokeNumber userRatings total =
    total + extractOnePokemonFromRatingString userRatings.ratings pokeNumber


addTeamVotes : TeamRatings -> Pokemon -> PokeRankings -> PokeRankings
addTeamVotes teamRatings pokemon rankings =
    let
        totalVotes =
            List.foldl (addUserVote pokemon.number) 0 teamRatings

        ranking =
            { number = pokemon.number
            , name = pokemon.name
            , totalVotes = totalVotes
            }
    in
        ranking :: rankings


calculateRankings : ApplicationState -> PokeRankings
calculateRankings model =
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
        List.foldl (addTeamVotes teamRatings) [] pokelist
