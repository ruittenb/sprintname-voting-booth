module View.Application exposing (title, applicationPane, functionPane)

import Time exposing (Time, second)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput, onSubmit)
import RemoteData exposing (WebData, RemoteData(..))
import Control.Debounce exposing (trailing)
import Helpers exposing (romanNumeral)
import Helpers.Pokemon exposing (filterPokedex)
import Helpers.Pages exposing (isPageLocked, getCurrentPage, getWinner)
import Helpers.Authentication exposing (tryGetUserProfile, isLoggedIn)
import Helpers.Application exposing (getIsCurrentUserAdmin)
import Msgs exposing (Msg(..))
import Models exposing (..)
import Models.Settings exposing (RemoteSettings)
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
            [ button
                [ class "user-button"
                , onClick buttonMsg
                ]
                [ text buttonText ]
            , div
                [ id "user-name"
                , classList
                    [ ( "current", loggedIn )
                    ]
                ]
                [ text userName ]
            ]


maintenanceButton : RemoteSettings -> Bool -> Html Msg
maintenanceButton remoteSettings isCurrentUserAdmin =
    let
        placeHolder =
            div [ class "button button-spacer" ] []

        buttonHtml =
            remoteSettings
                |> RemoteData.map
                    (\settings ->
                        a
                            [ classList
                                [ ( "button", True )
                                , ( "maintenance-button", True )
                                , ( "maintenance-mode", settings.maintenanceMode )
                                ]
                            , onClick MaintenanceModeClicked
                            , Html.Attributes.title "maintenance mode"
                            ]
                            []
                    )
                |> RemoteData.withDefault placeHolder
    in
        if isCurrentUserAdmin then
            buttonHtml
        else
            placeHolder


lockButton : Route -> Maybe Page -> Bool -> Int -> Char -> Html Msg
lockButton currentRoute currentPage isCurrentUserAdmin generation letter =
    let
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
                , ( "search", not isRouteBrowse )
                ]
            ]

        titleProps =
            [ Html.Attributes.title <|
                if isCurrentUserAdmin && isLocked then
                    "voting has closed (click to open)"
                else if isCurrentUserAdmin then
                    "open for voting (click to close)"
                else if isLocked then
                    "voting has closed"
                else
                    "open for voting"
            ]

        eventProps =
            currentPage
                |> Maybe.map (\page -> [ onClick (PageLockClicked page) ])
                |> Maybe.withDefault []
    in
        if isRouteBrowse && isCurrentUserAdmin && currentPage /= Nothing then
            a (classProps ++ titleProps ++ eventProps) []
        else
            span (classProps ++ titleProps) []


calculationButtons : Route -> RemotePages -> Maybe Page -> Bool -> Int -> Char -> Html Msg
calculationButtons route remotePages currentPage isCurrentUserAdmin generation letter =
    let
        calculationButtonElement =
            case route of
                Search _ ->
                    span

                _ ->
                    if currentPage == Nothing then
                        span
                    else
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
            , lockButton route currentPage isCurrentUserAdmin generation letter
            ]


rankingsTable : ApplicationState -> Maybe Page -> Bool -> Html Msg
rankingsTable state currentPage isCurrentUserAdmin =
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

                winButtonCell : Int -> String -> List (Html Msg)
                winButtonCell number name =
                    case currentPage of
                        Nothing ->
                            []

                        Just page ->
                            -- current user needs to be admin.
                            -- current page must be open OR no winner known.
                            if isCurrentUserAdmin && (page.open || page.winnerNum == Nothing) then
                                [ td []
                                    [ button
                                        [ onClick (WinnerElected page (PokeWinner number name))
                                        , classList
                                            [ ( "elect-button", True )
                                            , ( "winner", page.winnerNum == Just number )
                                            ]
                                        ]
                                        [ text "win" ]
                                    ]
                                ]
                            else
                                []
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
                                    ([ td [] [ text r.name ]
                                     , td [] [ text (toString r.totalVotes) ]
                                     ]
                                        ++ winButtonCell r.number r.name
                                    )
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
        currentPage : Maybe Page
        currentPage =
            getCurrentPage state.pages state.generation state.letter

        isCurrentUserAdmin =
            getIsCurrentUserAdmin state
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
                currentPage
                isCurrentUserAdmin
                state.generation
                state.letter
            , tableMask
                state.currentRoute
            , votersTable
                state
            , rankingsTable
                state
                currentPage
                isCurrentUserAdmin
            ]


applicationPane : ApplicationState -> Html Msg
applicationPane state =
    let
        isCurrentUserAdmin =
            getIsCurrentUserAdmin state
    in
        div [ id "main-buttons" ]
            [ loginLogoutButton
                state.authModel
                state.currentUser
            , maintenanceButton
                state.settings
                isCurrentUserAdmin
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
