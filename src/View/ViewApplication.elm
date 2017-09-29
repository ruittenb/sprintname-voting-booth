module ViewApplication exposing (..)

import Char
import Html exposing (..)
import Html.Attributes exposing (..)
import ViewHelper exposing (..)
import Msgs exposing (Msg)
import Model exposing (..)


generaties : List Int
generaties =
    List.range 1 7


letters : List Char
letters =
    List.map Char.fromCode <|
        List.range (Char.toCode 'A') (Char.toCode 'Z')


letterButton : Char -> Char -> Html Msg
letterButton currentLetter letter =
    let
        currentClass =
            if letter == currentLetter then
                "letter-button current"
            else
                "letter-button"
    in
        button [ class currentClass ] [ text <| String.fromChar letter ]


letterButtons : Char -> Html Msg
letterButtons currentLetter =
    div [] <|
        List.map
            (letterButton currentLetter)
            letters


romanNumeralButton : Int -> Int -> Html Msg
romanNumeralButton currentGen gen =
    let
        currentClass =
            if gen == currentGen then
                "generation-button current"
            else
                "generation-button"
    in
        button [ class currentClass ] [ text <| romanNumeral gen ]


romanNumeralButtons : Int -> Html Msg
romanNumeralButtons currentGen =
    div [] <|
        List.map
            (romanNumeralButton currentGen)
            generaties


heading : ApplicationState -> Html Msg
heading state =
    div []
        [ romanNumeralButtons state.generation
        , p [] []
        , letterButtons state.letter
        ]
