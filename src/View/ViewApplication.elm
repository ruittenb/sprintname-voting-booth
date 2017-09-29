module ViewApplication exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import ViewHelper exposing (..)
import Msgs exposing (Msg)
import Model exposing (..)
import Constants exposing (..)


letterButton : Char -> Char -> Html Msg
letterButton currentLetter letter =
    button
        [ classList
            [ ( "letter-button", True )
            , ( "current", letter == currentLetter )
            ]
        , onClick (Msgs.ChangeLetter letter)
        ]
        [ text <| String.fromChar letter ]


letterButtons : Char -> Html Msg
letterButtons currentLetter =
    div [] <|
        List.map
            (letterButton currentLetter)
            allLetters


romanNumeralButton : Int -> Int -> Html Msg
romanNumeralButton currentGen gen =
    button
        [ classList
            [ ( "generation-button", True )
            , ( "current", gen == currentGen )
            ]
        , onClick (Msgs.ChangeGeneration gen)
        ]
        [ text <| romanNumeral gen ]


romanNumeralButtons : Int -> Html Msg
romanNumeralButtons currentGen =
    div [] <|
        List.map
            (romanNumeralButton currentGen)
            allGenerations


heading : ApplicationState -> Html Msg
heading state =
    div []
        [ romanNumeralButtons state.generation
        , letterButtons state.letter
        ]
