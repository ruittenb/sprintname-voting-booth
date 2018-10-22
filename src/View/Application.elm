module View.Application exposing (heading, title)

import Time exposing (Time, second)
import Html exposing (..)
import Html.Attributes exposing (attribute, id, href, class, classList, tabindex, placeholder, disabled, value)
import Html.Events exposing (onClick, onInput, onSubmit)
import RemoteData exposing (WebData, RemoteData(..))
import Control.Debounce exposing (trailing)
import Helpers exposing (filterPokedex, romanNumeral)
import Helpers.Authentication exposing (tryGetUserProfile, isLoggedIn)
import Msgs exposing (Msg(..))
import Models exposing (..)
import Models.Types exposing (..)
import Models.Authentication exposing (AuthenticationModel)
import Models.Pokemon exposing (..)
import Constants exposing (..)
import View.Calculations exposing (calculateRankings, calculateVoters)


messageBox : String -> StatusLevel -> Html Msg
messageBox message level =
    let
        autohide =
            String.length message > 0 && level /= Error
    in
        span [ id "message-box-container" ]
            [ div
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


romanNumeralButton : Route -> Int -> Char -> Int -> Html Msg
romanNumeralButton currentRoute currentGen currentLetter gen =
    let
        currentHighLight =
            case currentRoute of
                Search _ ->
                    False

                _ ->
                    gen == currentGen

        hash =
            "#/" ++ browsePathSegment ++ "/" ++ (toString gen) ++ (String.fromChar currentLetter)
    in
        a
            [ classList
                [ ( "button", True )
                , ( "generation-button", True )
                , ( "current", currentHighLight )
                , ( "transparent", gen == 0 )
                ]
            , href hash
            ]
            [ text <| romanNumeral gen ]


debounce : Msg -> Msg
debounce =
    Control.Debounce.trailing
        DebounceSearchPokemon
        (debounceDelay * Time.second)


searchBox : Route -> Html Msg
searchBox currentRoute =
    let
        valueAttribute =
            case currentRoute of
                Search query ->
                    [ value query ]

                _ ->
                    []

        searching =
            case currentRoute of
                Search _ ->
                    True

                _ ->
                    False
    in
        div
            [ id "search-box-container"
            , classList [ ( "focus", searching ) ]
            ]
            [ input
                [ id "search-box"
                , classList [ ( "current", searching ) ]
                , placeholder "Search in pokédex"
                , onInput Msgs.SearchPokemon
                    |> Html.Attributes.map debounce
                ]
                []
            ]


romanNumeralButtons : Route -> Int -> Char -> Html Msg
romanNumeralButtons currentRoute currentGen currentLetter =
    div [ id "generation-buttons" ] <|
        (List.map
            (romanNumeralButton currentRoute currentGen currentLetter)
            allGenerations
        )


letterButton : Route -> RemotePokedex -> Int -> Char -> Char -> Html Msg
letterButton currentRoute pokedex currentGen currentLetter letter =
    let
        currentHighLight =
            case currentRoute of
                Search _ ->
                    False

                _ ->
                    letter == currentLetter

        pokeList =
            filterPokedex pokedex currentGen letter

        hash =
            "#/" ++ browsePathSegment ++ "/" ++ (toString currentGen) ++ (String.fromChar letter)

        linkElem =
            if List.isEmpty pokeList then
                span
            else
                a
    in
        linkElem
            [ classList
                [ ( "button", True )
                , ( "letter-button", True )
                , ( "current", currentHighLight )
                , ( "disabled", List.isEmpty pokeList )
                ]
            , href hash
            ]
            [ String.fromChar letter |> text ]


letterButtons : Route -> RemotePokedex -> Int -> Char -> Html Msg
letterButtons currentRoute pokedex currentGen currentLetter =
    let
        buttonList =
            case pokedex of
                Success _ ->
                    List.map
                        (letterButton currentRoute pokedex currentGen currentLetter)
                        allLetters

                _ ->
                    []
    in
        div [ id "letter-buttons" ] buttonList


loginLogoutButton : AuthenticationModel -> User -> String -> StatusLevel -> Html Msg
loginLogoutButton authModel currentUser message level =
    let
        loggedIn =
            isLoggedIn authModel

        userName =
            if not loggedIn then
                "Not logged in"
            else
                Maybe.map ((++) "Logged in as ") currentUser
                    |> Maybe.withDefault "Not authorized"

        buttonText =
            if loggedIn then
                "Logout"
            else
                "Login"

        buttonMsg =
            if loggedIn then
                AuthenticationLogoutClicked
            else
                AuthenticationLoginClicked
    in
        div [ id "user-buttons" ]
            [ div
                [ id "user-name"
                , classList
                    [ ( "current", loggedIn )
                    ]
                ]
                [ text userName ]
            , button
                [ class "user-button"
                , onClick buttonMsg
                ]
                [ text buttonText ]
            , div
                [ class "button button-spacer" ]
                []
            , messageBox message level
            ]


calculationButtons : Html Msg
calculationButtons =
    div
        [ id "calculation-buttons"
        ]
        [ button
            [ class "show-rankings"
            , onClick ShowRankingsClicked
            ]
            [ text "Show Rankings" ]
        , button
            [ class "show-voters"
            , onClick ShowVotersClicked
            ]
            [ text "Show Voters" ]
        ]


rankingsTable : ApplicationState -> Html Msg
rankingsTable state =
    let
        rankingsToShow =
            calculateRankings state
                |> List.sortBy .totalVotes
                |> List.reverse

        winnerRating =
            case List.head rankingsToShow of
                Just winner ->
                    winner.totalVotes

                Nothing ->
                    0

        resultTable =
            case state.viewMode of
                Search ->
                    span [] []

                Browse ->
                    div [ class "ranking-table-wrapper" ]
                        [ table [ class "ranking-table" ] <|
                            List.map
                                (\r ->
                                    tr
                                        [ classList
                                            [ ( "winner-rating", r.totalVotes == winnerRating && r.totalVotes > 0 ) ]
                                        ]
                                        [ td [] [ text r.name ]
                                        , td [] [ text (toString r.totalVotes) ]
                                        ]
                                )
                                rankingsToShow
                        ]
    in
        resultTable


heading : ApplicationState -> Html Msg
heading state =
    div [ id "filter-buttons" ]
        [ loginLogoutButton
            state.authModel
            state.currentUser
            state.statusMessage
            state.statusLevel
        , romanNumeralButtons
            state.currentRoute
            state.generation
            state.letter
        , searchBox
            state.currentRoute
        , letterButtons
            state.currentRoute
            state.pokedex
            state.generation
            state.letter
        , calculationButtons
        , rankingsTable state
        ]


title : Html msg
title =
    h1
        [ id "page-title"
        ]
        [ text "Pokémon Sprint Name Voting Booth" ]
