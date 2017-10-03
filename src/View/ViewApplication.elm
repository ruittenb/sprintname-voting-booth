module ViewApplication exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import RemoteData exposing (..)
import Helpers exposing (..)
import Msgs exposing (Msg)
import Models exposing (..)
import Constants exposing (..)


messageBox : String -> StatusLevel -> Html Msg
messageBox message level =
    span [ id "message-box-container" ]
        [ span
            [ id "message-box"
            , classList
                [ ( "autohide", String.length message > 0 )
                , ( "notice", level == Notice )
                , ( "error", level == Error )
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


romanNumeralButtons : Int -> String -> StatusLevel -> Html Msg
romanNumeralButtons currentGen message level =
    div [ id "generation-buttons" ] <|
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
    div [ id "letter-buttons" ] <|
        List.map
            (letterButton pokedex currentGen currentLetter)
            allLetters


userButton : String -> String -> Html Msg
userButton currentUserName userName =
    button
        [ classList
            [ ( "user-button", True )
            , ( "current", userName == currentUserName )
            ]
        , onClick (Msgs.ChangeUser userName)
        ]
        [ text userName ]


userButtons : WebData TeamRatings -> CurrentUser -> Html Msg
userButtons ratings currentUser =
    case ratings of
        RemoteData.Success actualRatings ->
            let
                currentUserName =
                    Maybe.withDefault "" currentUser
            in
                div [ id "user-buttons" ] <|
                    List.map
                        (.userName >> userButton currentUserName)
                        (List.sortBy .userName actualRatings)

        _ ->
            div [ id "user-button-placeholder" ] []


heading : ApplicationState -> Html Msg
heading state =
    div [ id "filter-buttons" ]
        [ userButtons state.ratings state.user
        , romanNumeralButtons state.generation state.statusMessage state.statusLevel
        , letterButtons state.pokedex state.generation state.letter
        ]
