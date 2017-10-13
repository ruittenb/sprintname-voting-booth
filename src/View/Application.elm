module View.Application exposing (heading)

import Array exposing (Array)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Authentication exposing (tryGetUserProfile, isLoggedIn)
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
            ++ [ input
                    [ placeholder "Search in pokédex"
                    , id "search-box"
                    , onInput Msgs.SearchPokemon
                    ]
                    []
               ]


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


loginLogoutButton : Authentication.Model -> CurrentUser -> String -> StatusLevel -> Html Msg
loginLogoutButton authModel user message level =
    let
        loggedIn =
            isLoggedIn authModel

        buttonText =
            if loggedIn then
                "Logout " ++ Maybe.withDefault "" user
            else
                "Login"

        buttonMsg =
            if loggedIn then
                Authentication.LogOut
            else
                Authentication.ShowLogIn
    in
        div [ id "user-buttons" ] <|
            [ button
                [ classList
                    [ ( "user-button", True )
                    , ( "current", loggedIn )
                    ]
                , onClick (Msgs.AuthenticationMsg buttonMsg)
                ]
                [ text buttonText ]
            ]
                ++ [ messageBox message level ]


heading : ApplicationState -> Html Msg
heading state =
    div [ id "filter-buttons" ]
        [ loginLogoutButton
            state.authModel
            state.user
            state.statusMessage
            state.statusLevel
        , romanNumeralButtons
            state.generation
        , letterButtons
            state.pokedex
            state.generation
            state.letter
        ]
