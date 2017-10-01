module ViewApplication exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Helpers exposing (..)
import Msgs exposing (Msg)
import Models exposing (..)
import Constants exposing (..)


messageBox : String -> String -> Html Msg
messageBox message level =
    span [ id "msgBoxContainer" ]
        [ span
            [ id "messageBox"
            , classList
                [ ( "autohide", String.length message > 0 )
                , ( level, String.length level > 0 )
                ]
            ]
            [ text message ]
        ]


romanNumeral : Int -> String
romanNumeral i =
    case i of
        0 ->
            "O"

        1 ->
            "I"

        2 ->
            "II"

        3 ->
            "III"

        4 ->
            "IV"

        5 ->
            "V"

        6 ->
            "VI"

        7 ->
            "VII"

        _ ->
            "?"


romanNumeralButton : Int -> Int -> Html Msg
romanNumeralButton currentGen gen =
    button
        [ classList
            [ ( "generation-button", True )
            , ( "current", gen == currentGen )
            , ( "transparent", gen == 0 )
            ]
        , onClick (Msgs.ChangeGeneration gen)
        ]
        [ text <| romanNumeral gen ]


romanNumeralButtons : Int -> String -> String -> Html Msg
romanNumeralButtons currentGen message level =
    div [ id "generationButtons" ] <|
        (List.map
            (romanNumeralButton currentGen)
            allGenerations
        )
            ++ [ messageBox message level ]


letterButton : Pokedex -> Int -> Char -> Char -> Html Msg
letterButton pokedex currentGen currentLetter letter =
    let
        pokeList =
            filterPokedex pokedex currentGen letter
    in
        button
            [ classList
                [ ( "letter-button", True )
                , ( "current", letter == currentLetter )
                ]
            , onClick (Msgs.ChangeLetter letter)
            , disabled (List.isEmpty pokeList)
            ]
            [ text <| String.fromChar letter ]


letterButtons : Pokedex -> Int -> Char -> Html Msg
letterButtons pokedex currentGen currentLetter =
    div [ id "letterButtons" ] <|
        List.map
            (letterButton pokedex currentGen currentLetter)
            allLetters


heading : ApplicationState -> Html Msg
heading state =
    div [ id "filterButtons" ]
        [ romanNumeralButtons state.generation state.statusMessage state.statusLevel
        , letterButtons state.pokedex state.generation state.letter
        ]
