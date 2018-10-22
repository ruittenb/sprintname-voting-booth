module View.Calculations exposing (calculateVoters)

import Html
import Models exposing (..)
import Helpers exposing (filterPokedex)


addVoterVotes : TeamRatings -> Pokemon -> List PokeVotes -> List PokeVotes
addVoterVotes teamRatings pokemon pokevotes =
    5


calculateVoters : ApplicationState -> Html msg
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
            List.foldl (addVoterVotes teamRatings) [] pokelist
    in
        div [] [ text "voters here" ]
