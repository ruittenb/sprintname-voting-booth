module Update exposing (..)

import Msgs exposing (Msg)
import Model exposing (..)
import UpdateHelper exposing (..)
import Constants exposing (..)


update : Msg -> ApplicationState -> ApplicationState
update msg oldState =
    case msg of
        Msgs.ChangeGeneration newGen ->
            if List.member newGen allGenerations then
                { oldState | generation = newGen }
            else
                oldState

        Msgs.ChangeLetter newLetter ->
            if List.member newLetter allLetters then
                { oldState | letter = newLetter }
            else
                oldState

        Msgs.VoteForPokemon userVote ->
            {-
               let
                   allVotes =
                       newPokemon.votes

                   validVotes =
                       List.filter (numberBetween 0 3) allVotes

                   allVotesValid =
                       (List.length allVotes) == (List.length validVotes)
               in
            -}
            if True then
                oldState
            else
                oldState
