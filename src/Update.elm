module Update exposing (..)

import Commands exposing (..)
import Msgs exposing (Msg)
import Models exposing (..)
import UpdateHelper exposing (..)
import Constants exposing (..)


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
            if False then
                ( oldState, Cmd.none )
            else
                ( oldState, Cmd.none )
