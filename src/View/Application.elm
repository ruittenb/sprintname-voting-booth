module View.Application exposing (title, applicationPane, functionPane)

import Time exposing (Time, second)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput, onSubmit)
import RemoteData exposing (WebData, RemoteData(..))
import Control.Debounce exposing (trailing)
import Helpers exposing (romanNumeral)
import Helpers.Pokemon exposing (filterPokedex, extractOneUserFromRatings)
import Helpers.Pages exposing (isPageLocked, getCurrentPage, getWinner)
import Helpers.Authentication exposing (tryGetUserProfile, isLoggedIn)
import Msgs exposing (Msg(..))
import Models exposing (..)
import Models.Types exposing (..)
import Models.Authentication exposing (AuthenticationModel)
import Models.Pokemon exposing (..)
import Models.Pages exposing (..)
import Models.Ratings exposing (..)
import Constants exposing (..)
import Routing
    exposing
        ( createBrowsePath
        , createShowRankingsPath
        , createShowVotersPath
        )
import View.Calculations
    exposing
        ( calculatePeopleVotes
        , calculatePokemonVotes
        )


messageBox : String -> StatusLevel -> Html Msg
messageBox message level =
    div
        [ id "message-box"
        , classList
            [ ( "debug", level == Debug )
            , ( "notice", level == Notice )
            , ( "warning", level == Warning || level == Maintenance )
            , ( "error", level == Error )
            ]
        ]
        [ text message ]


generationButton : Route -> Int -> Char -> Int -> Html Msg
generationButton currentRoute currentGen currentLetter gen =
    let
        currentHighLight =
            case currentRoute of
                Search _ ->
                    False

                _ ->
                    gen == currentGen

        hash =
            createBrowsePath gen currentLetter
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


searchBox : Route -> String -> Html Msg
searchBox currentRoute modelQuery =
    let
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
                , type_ "search"
                , defaultValue modelQuery
                , classList [ ( "current", searching ) ]
                , placeholder "Search in pokédex"
                , onInput Msgs.SearchPokemon
                    |> Html.Attributes.map debounce
                ]
                []
            ]


generationButtons : Route -> Int -> Char -> Html Msg
generationButtons currentRoute currentGen currentLetter =
    div [ id "generation-buttons" ] <|
        (List.map
            (generationButton currentRoute currentGen currentLetter)
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
            createBrowsePath currentGen letter

        letterButtonElement =
            if List.isEmpty pokeList then
                span
            else
                a
    in
        letterButtonElement
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

                Failure _ ->
                    []

                _ ->
                    let
                        placeholder =
                            div
                                [ classList
                                    [ ( "button", True )
                                    , ( "letter-button-placeholder", True )
                                    , ( "loading", False )
                                    , ( "disabled", True )
                                    ]
                                ]
                    in
                        [ placeholder [ text "Loading..." ]
                        , placeholder []
                        ]
    in
        div [ id "letter-buttons" ] buttonList


loginLogoutButton : AuthenticationModel -> User -> Html Msg
loginLogoutButton authModel currentUser =
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
            ]


lockButton: Route -> RemotePages -> Bool -> Int -> Char -> Html Msg
lockButton currentRoute remotePages isCurrentUserAdmin generation letter =
    let
        currentPage =
            getCurrentPage remotePages generation letter

        isLocked =
            isPageLocked currentRoute currentPage

        isRouteBrowse =
            case currentRoute of
                Search _ ->
                    False

                _ ->
                    True

        classProps =
            [ classList
                [ ( "button", True )
                , ( "lock-button", True )
                , ( "locked", isLocked )
                ]
            ]

        eventProps =
            [ onClick (PageLockClicked currentPage) ]
    in
        if isRouteBrowse && isCurrentUserAdmin then
            a (classProps ++ eventProps) []
        else
            span classProps []


calculationButtons : Route -> RemotePages -> Bool -> Int -> Char -> Html Msg
calculationButtons route remotePages isCurrentUserAdmin generation letter =
    let
        calculationButtonElement =
            case route of
                Search _ ->
                    span

                _ ->
                    a
    in
        div
            [ id "calculation-buttons"
            ]
            [ calculationButtonElement
                [ classList
                    [ ( "show-voters", True )
                    , ( "button", True )
                    ]
                , href (createShowVotersPath generation letter)
                ]
                [ text "Show Voters" ]
            , calculationButtonElement
                [ classList
                    [ ( "show-rankings", True )
                    , ( "button", True )
                    ]
                , href (createShowRankingsPath generation letter)
                ]
                [ text "Show Rankings" ]
            , lockButton route remotePages isCurrentUserAdmin generation letter
            ]


rankingsTable : ApplicationState -> Html Msg
rankingsTable state =
    case state.currentRoute of
        BrowseWithPokemonRankings _ ->
            let
                rankingsToShow =
                    calculatePokemonVotes state
                        |> List.sortBy .totalVotes
                        |> List.reverse

                winnerRating =
                    case List.head rankingsToShow of
                        Just winner ->
                            winner.totalVotes

                        Nothing ->
                            0
            in
                div
                    [ class "rankings-table-wrapper" ]
                    [ table [ class "rankings-table" ] <|
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

        _ ->
            span [] []


votersTable : ApplicationState -> Html Msg
votersTable state =
    case state.currentRoute of
        BrowseWithPeopleVotes _ ->
            let
                votersToShow =
                    calculatePeopleVotes state
                        |> List.sortBy .userId
            in
                div
                    [ class "voters-table-wrapper" ]
                    [ table [ class "voters-table" ] <|
                        List.map
                            (\v ->
                                tr
                                    [ classList
                                        [ ( "complete", v.completionLevel == Complete )
                                        , ( "incomplete", v.completionLevel == Incomplete )
                                        , ( "absent", v.completionLevel == Absent )
                                        ]
                                    ]
                                    [ td [] [ text v.userName ]
                                    , td [] [ text (toString v.totalVotes) ]
                                    ]
                            )
                            votersToShow
                    ]

        _ ->
            span [] []


tableMask : Route -> Html Msg
tableMask route =
    let
        maskDiv =
            div
                [ class "mask"
                , onClick CloseMaskClicked
                ]
                []
    in
        case route of
            BrowseWithPokemonRankings _ ->
                maskDiv

            BrowseWithPeopleVotes _ ->
                maskDiv

            _ ->
                span [] []


functionPane : ApplicationState -> Html Msg
functionPane state =
    let
        ( currentUserDataList, _ ) =
            state.ratings
                |> RemoteData.map
                    (\ratings -> extractOneUserFromRatings ratings state.currentUser)
                |> RemoteData.withDefault
                    ( [], [] )

        isCurrentUserAdmin =
            List.head currentUserDataList
                |> Maybe.map .admin
                |> Maybe.withDefault False

    in
        div [ id "function-buttons" ]
            [ generationButtons
                state.currentRoute
                state.generation
                state.letter
            , searchBox
                state.currentRoute
                state.query
            , letterButtons
                state.currentRoute
                state.pokedex
                state.generation
                state.letter
            , calculationButtons
                state.currentRoute
                state.pages
                isCurrentUserAdmin
                state.generation
                state.letter
            , tableMask
                state.currentRoute
            , votersTable
                state
            , rankingsTable
                state
            ]


applicationPane : ApplicationState -> Html Msg
applicationPane state =
    div [ id "main-buttons" ]
        [ loginLogoutButton
            state.authModel
            state.currentUser
        , messageBox
            state.statusMessage
            state.statusLevel
        ]


title : Html msg
title =
    h1
        [ id "page-title"
        ]
        [ text "Pokémon Sprint Name Voting Booth" ]
