module Update exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Msgs exposing (Msg)
import Model exposing (..)
import UpdateHelper exposing (..)


updateVote : Msg msg -> Pokemon -> Pokemon
updateVote msg oldPokemon =
    case msg of
        Msg.VoteForPokemon newPokemon ->
            let
                allVotes =
                    newPokemon.votes

                validVotes =
                    List.filter (numberBetween 0 3) allVotes

                allVotesValid =
                    (List.length allVotes) == (List.length validVotes)
            in
                if allVotesValid then
                    newPokemon
                else
                    oldPokemon

        _ ->
            oldPokemon
