module ViewApplication exposing (heading)

import Array exposing (Array)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import RemoteData exposing (WebData, RemoteData(..))
import Helpers exposing (filterPokedex)
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
                , ( "debug", level == Debug )
                , ( "notice", level == Notice )
                , ( "warning", level == Warning )
                , ( "error", level == Error )
                ]
            ]
            [ text message ]
        ]


romanNumerals : Array String
romanNumerals =
    Array.fromList [ "O", "I", "II", "III", "IV", "V", "VI", "VII" ]


romanNumeral : Int -> String
romanNumeral i =
    let
        roman =
            Array.get i romanNumerals
    in
        case roman of
            Just actualRoman ->
                actualRoman

            Nothing ->
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


romanNumeralButtons : Int -> Html Msg
romanNumeralButtons currentGen =
    div [ id "generation-buttons" ] <|
        (List.map
            (romanNumeralButton currentGen)
            allGenerations
        )


letterButton : WebData Pokedex -> Int -> Char -> Char -> Html Msg
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


letterButtons : WebData Pokedex -> Int -> Char -> Html Msg
letterButtons pokedex currentGen currentLetter =
    let
        buttonList =
            case pokedex of
                Success pokeList ->
                    List.map
                        (letterButton pokedex currentGen currentLetter)
                        allLetters

                _ ->
                    []
    in
        div [ id "letter-buttons" ] buttonList


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


userButtons : WebData TeamRatings -> CurrentUser -> String -> StatusLevel -> Html Msg
userButtons ratings currentUser message level =
    case ratings of
        Success actualRatings ->
            let
                currentUserName =
                    Maybe.withDefault "" currentUser
            in
                div [ id "user-buttons" ] <|
                    List.map
                        (.userName >> userButton currentUserName)
                        (List.sortBy .userName actualRatings)
                        ++ [ messageBox message level ]

        _ ->
            div [ id "user-button-placeholder" ]
                [ messageBox message level
                ]


heading : ApplicationState -> Html Msg
heading state =
    div [ id "filter-buttons" ]
        [ userButtons state.ratings state.user state.statusMessage state.statusLevel
        , romanNumeralButtons state.generation
        , letterButtons state.pokedex state.generation state.letter
        ]
