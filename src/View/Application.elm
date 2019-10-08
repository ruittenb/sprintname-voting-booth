module View.Application exposing (title, applicationPane, functionPane)

import Time exposing (Time, second)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput, onSubmit)
import RemoteData exposing (WebData, RemoteData(..))
import Control.Debounce exposing (trailing)
import Helpers exposing (romanNumeral)
import Helpers.Pokemon exposing (slicePokedex)
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
        , createDefaultPath
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


generationButton : Route -> Maybe SubPage -> Int -> Html Msg
generationButton currentRoute currentSubPage gen =
    let
        currentHighLight =
            case currentRoute of
                Browse _ ->
                    currentSubPage
                        |> Maybe.map (.generation >> (==) gen)
                        |> Maybe.withDefault False

                _ ->
                    False

        hash =
            currentSubPage
                |> Maybe.map (.letter >> createBrowsePath gen)
                |> Maybe.withDefault createDefaultPath
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


generationButtons : Route -> Maybe SubPage -> Html Msg
generationButtons currentRoute subPage =
    div [ id "generation-buttons" ] <|
        (List.map
            (generationButton currentRoute subPage)
            allGenerations
        )


letterButton : Route -> RemotePokedex -> Maybe SubPage -> Char -> Html Msg
letterButton currentRoute pokedex currentSubPage letter =
    let
        currentHighLight =
            case currentRoute of
                Browse _ ->
                    currentSubPage
                        |> Maybe.map (.letter >> (==) letter)
                        |> Maybe.withDefault False

                _ ->
                    False

        hash =
            currentSubPage
                |> Maybe.map (\subPage -> createBrowsePath subPage.generation letter)
                |> Maybe.withDefault createDefaultPath

        pokeList =
            currentSubPage
                |> Maybe.map (\subPage -> slicePokedex pokedex subPage.generation letter)
                |> Maybe.withDefault []

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


letterButtons : Route -> RemotePokedex -> Maybe SubPage -> Html Msg
letterButtons currentRoute pokedex subPage =
    let
        buttonList =
            case pokedex of
                Success _ ->
                    List.map
                        (letterButton currentRoute pokedex subPage)
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


lockButton : Route -> Maybe Page -> Bool -> Html Msg
lockButton currentRoute currentPage isCurrentUserAdmin =
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


calculationButtons : Route -> RemotePages -> Maybe Page -> Bool -> Maybe SubPage -> Html Msg
calculationButtons route remotePages currentPage isCurrentUserAdmin currentSubPage =
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

        showVotersHash =
            currentSubPage
                |> Maybe.map (\subPage -> createShowVotersPath subPage.generation subPage.letter)
                |> Maybe.withDefault createDefaultPath

        showRankingsHash =
            currentSubPage
                |> Maybe.map (\subPage -> createShowRankingsPath subPage.generation subPage.letter)
                |> Maybe.withDefault createDefaultPath
    in
        div
            [ id "calculation-buttons"
            ]
            [ calculationButtonElement
                [ classList
                    [ ( "show-voters", True )
                    , ( "button", True )
                    ]
                , href showVotersHash
                ]
                [ text "Show Voters" ]
            , calculationButtonElement
                [ classList
                    [ ( "show-rankings", True )
                    , ( "button", True )
                    ]
                , href showRankingsHash
                ]
                [ text "Show Rankings" ]
            , lockButton route currentPage isCurrentUserAdmin
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
                            if isCurrentUserAdmin then
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
        BrowseWithPeopleVotes subPage ->
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
            getCurrentPage state.pages state.subPage

        isCurrentUserAdmin =
            getIsCurrentUserAdmin state
    in
        div [ id "function-buttons" ]
            [ generationButtons
                state.currentRoute
                state.subPage
            , searchBox
                state.currentRoute
                state.query
            , letterButtons
                state.currentRoute
                state.pokedex
                state.subPage
            , calculationButtons
                state.currentRoute
                state.pages
                currentPage
                isCurrentUserAdmin
                state.subPage
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
