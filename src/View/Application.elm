module View.Application exposing (heading)

import Html exposing (..)
import Html.Attributes exposing (id, class, classList, tabindex, placeholder, disabled)
import Html.Events exposing (onClick, onInput)
import Authentication exposing (tryGetUserProfile, isLoggedIn)
import RemoteData exposing (WebData, RemoteData(..))
import Helpers exposing (filterPokedex, romanNumeral)
import Msgs exposing (Msg)
import Models exposing (..)
import Constants exposing (..)


messageBox : String -> StatusLevel -> Html Msg
messageBox message level =
    let
        autohide =
            String.length message > 0 && level /= Error
    in
        span [ id "message-box-container" ]
            [ span
                [ id "message-box"
                , classList
                    [ ( "autohide", autohide )
                    , ( "debug", level == Debug )
                    , ( "notice", level == Notice )
                    , ( "warning", level == Warning )
                    , ( "error", level == Error )
                    ]
                ]
                [ text message ]
            ]


romanNumeralButton : ViewMode -> Int -> Int -> Html Msg
romanNumeralButton viewMode currentGen gen =
    let
        currentHighLight =
            gen == currentGen && viewMode == Browse
    in
        button
            [ classList
                [ ( "generation-button", True )
                , ( "current", currentHighLight )
                , ( "transparent", gen == 0 )
                ]
            , onClick (Msgs.ChangeGeneration gen)
            ]
            [ text <| romanNumeral gen ]


searchBox : ViewMode -> Html Msg
searchBox viewMode =
    span
        [ id "search-box-container"
        , classList [ ( "focus", viewMode == Search ) ]
        ]
        [ input
            [ id "search-box"
            , classList [ ( "current", viewMode == Search ) ]
            , placeholder "Search in pokédex"
            , onInput Msgs.SearchPokemon
            ]
            []
        ]


romanNumeralButtons : ViewMode -> Int -> Html Msg
romanNumeralButtons viewMode currentGen =
    div [ id "generation-buttons" ] <|
        (List.map
            (romanNumeralButton viewMode currentGen)
            allGenerations
        )
            ++ [ searchBox viewMode ]


letterButton : ViewMode -> WebData Pokedex -> Int -> Char -> Char -> Html Msg
letterButton viewMode pokedex currentGen currentLetter letter =
    let
        currentHighLight =
            letter == currentLetter && viewMode == Browse

        pokeList =
            filterPokedex pokedex currentGen letter
    in
        button
            [ classList
                [ ( "letter-button", True )
                , ( "current", currentHighLight )
                ]
            , onClick (Msgs.ChangeLetter letter)
            , disabled (List.isEmpty pokeList)
            ]
            [ text <| String.fromChar letter ]


letterButtons : ViewMode -> WebData Pokedex -> Int -> Char -> Html Msg
letterButtons viewMode pokedex currentGen currentLetter =
    let
        buttonList =
            case pokedex of
                Success pokeList ->
                    List.map
                        (letterButton viewMode pokedex currentGen currentLetter)
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

        userName =
            if not loggedIn then
                "Not logged in"
            else
                Maybe.map ((++) "Logged in as ") user
                    |> Maybe.withDefault "Not authorized"

        buttonText =
            if loggedIn then
                "Logout"
            else
                "Login"

        buttonMsg =
            if loggedIn then
                Authentication.LogOut
            else
                Authentication.ShowLogIn
    in
        div [ id "user-buttons" ] <|
            [ div
                [ id "user-name"
                , classList
                    [ ( "current", loggedIn )
                    ]
                ]
                [ text userName ]
            , button
                [ class "user-button"
                , onClick (Msgs.AuthenticationMsg buttonMsg)
                ]
                [ text buttonText ]
            , messageBox message level
            ]


heading : ApplicationState -> Html Msg
heading state =
    div [ id "filter-buttons" ]
        [ loginLogoutButton
            state.authModel
            state.user
            state.statusMessage
            state.statusLevel
        , romanNumeralButtons
            state.viewMode
            state.generation
        , letterButtons
            state.viewMode
            state.pokedex
            state.generation
            state.letter
        ]
