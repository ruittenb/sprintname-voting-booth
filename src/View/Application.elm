module View.Application exposing (applicationPane, functionPane, title)

import Constants exposing (..)
import Control.Debounce exposing (trailing)
import Helpers.Application exposing (getIsCurrentUserAdmin)
import Helpers.Authentication exposing (isLoggedIn, tryGetUserProfile)
import Helpers.Pages exposing (getCurrentPage, getWinner, isPageLocked)
import Helpers.Pokemon exposing (filterPokedexByPage)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput, onSubmit)
import List.Extra exposing (find)
import Maybe.Extra exposing (unwrap)
import Models exposing (..)
import Models.Authentication exposing (AuthenticationModel)
import Models.Pages exposing (..)
import Models.Pokemon exposing (..)
import Models.Ratings exposing (..)
import Models.Settings exposing (RemoteSettings)
import Models.Types exposing (..)
import Msgs exposing (Msg(..))
import RemoteData exposing (RemoteData(..), WebData)
import Routing
    exposing
        ( createDefaultPath
        , createBrowseFreelyPath
        , createBrowseWithRankingsPath
        , createBrowseWithVotersPath
        , createBrowseWithCopyrightPath
        , createSearchFreelyPath
        , createSearchWithCopyrightPath
        )
import Time exposing (Time, second)
import View.Calculations
    exposing
        ( calculatePeopleVotes
        , calculatePokemonVotes
        )


blurOnEnterPressed : String
blurOnEnterPressed =
    "if (event.keyCode===13) { this.blur(); return false; }"


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
                Search _ _ ->
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
            , classList [ ( "current", searching ) ]
            , defaultValue modelQuery
            , placeholder "Search in pokédex"
            , attribute "aria-label" "Search in pokédex"
            , attribute "results" "5"
            , attribute "autosave" "pokemon-voting-booth"
            , attribute "onkeypress" blurOnEnterPressed -- collapse the keyboard on mobile devices
            , onInput Msgs.SearchPokemon
                |> Html.Attributes.map debounce
            ]
            []
        ]


generationButton : Route -> RemotePokedex -> Maybe SubPage -> String -> Html Msg
generationButton currentRoute pokedex currentSubPage gen =
    let
        currentHighLight =
            case currentRoute of
                Browse _ _ ->
                    currentSubPage
                        |> Maybe.map (.generation >> (==) gen)
                        |> Maybe.withDefault False

                _ ->
                    False

        hash =
            currentSubPage
                |> Maybe.map (.letter >> createBrowseFreelyPath gen)
                |> Maybe.withDefault createDefaultPath

        disableButton =
            pokedex
                |> RemoteData.toMaybe
                |> Maybe.andThen
                    (\actualPokedex ->
                        List.Extra.find
                            (.generation >> (==) gen)
                            actualPokedex
                    )
                |> (==) Nothing

        genButtonElement =
            if disableButton then
                span

            else
                a
    in
    genButtonElement
        [ classList
            [ ( "button", True )
            , ( "generation-button", True )
            , ( "with-tooltip", True )
            , ( "current", currentHighLight )
            , ( "transparent", gen == "O" )
            , ( "disabled", disableButton )
            ]
        , href hash
        ]
        [ text gen ]


pokeGenerationButtons : Route -> RemotePokedex -> Maybe SubPage -> Html Msg
pokeGenerationButtons currentRoute pokedex subPage =
    div [ id "poke-generation-buttons" ] <|
        List.map
            (generationButton currentRoute pokedex subPage)
            pokeGenerations

rdawGenerationButtons : Route -> RemotePokedex -> Maybe SubPage -> Html Msg
rdawGenerationButtons currentRoute pokedex subPage =
    div [ id "rdaw-generation-buttons" ] <|
        List.map
            (generationButton currentRoute pokedex subPage)
            rdawGenerations


letterButton : Route -> RemotePokedex -> Maybe SubPage -> Char -> Html Msg
letterButton currentRoute pokedex currentSubPage letter =
    let
        currentHighLight =
            case currentRoute of
                Browse _ _ ->
                    currentSubPage
                        |> Maybe.map (.letter >> (==) letter)
                        |> Maybe.withDefault False

                _ ->
                    False

        hash =
            currentSubPage
                |> Maybe.map (\subPage -> createBrowseFreelyPath subPage.generation letter)
                |> Maybe.withDefault createDefaultPath

        pokeList =
            currentSubPage
                |> Maybe.andThen (\subPage -> filterPokedexByPage pokedex subPage.generation letter)
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
            , ( "with-tooltip", True )
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
            List.map
                (letterButton currentRoute pokedex subPage)
                allLetters
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
                                , ( "with-tooltip", True )
                                ]
                            , onClick MaintenanceModeClicked
                            ]
                            []
                    )
                |> RemoteData.withDefault placeHolder
    in
    if isCurrentUserAdmin then
        buttonHtml

    else
        placeHolder


copyrightButton : Route -> Maybe SubPage -> Html Msg
copyrightButton route currentSubPage =
    let 
        subPageToHash =
            (\subPage ->
                case route of
                    Search _ query ->
                        createSearchWithCopyrightPath query

                    Browse _ _ ->
                        createBrowseWithCopyrightPath subPage.generation subPage.letter

                    Default ->
                        ""
            )

        showCopyrightHash =
            currentSubPage
            |> Maybe.map subPageToHash
            |> Maybe.withDefault createDefaultPath
    in
    a 
        [ classList
            [ ( "button", True )
            , ( "copyright-button", True )
            ]
            , href showCopyrightHash
        ]
        [
            text "©"
        ]


homeButton : Html Msg
homeButton =
    let
        props =
            [ classList
                [ ( "button", True )
                , ( "home-button", True )
                ]
            , attribute "href" "#"
            ]
    in
    a props []


lockButton : Route -> Maybe Page -> Bool -> Html Msg
lockButton currentRoute currentPage isCurrentUserAdmin =
    let
        isLocked =
            isPageLocked currentRoute currentPage

        isRouteBrowse =
            case currentRoute of
                Search _ _ ->
                    False

                _ ->
                    True

        classProps =
            [ classList
                [ ( "button", True )
                , ( "lock-button", True )
                , ( "with-tooltip", True )
                , ( "for-admin", isCurrentUserAdmin )
                , ( "locked", isLocked )
                , ( "search", not isRouteBrowse )
                ]
            ]

        eventProps =
            currentPage
                |> Maybe.map (\page -> [ onClick (PageLockClicked page) ])
                |> Maybe.withDefault []
    in
    if isRouteBrowse && isCurrentUserAdmin && currentPage /= Nothing then
        a (classProps ++ eventProps) []

    else
        span classProps []


calculationButtons : Route -> RemotePages -> Maybe Page -> Bool -> Maybe SubPage -> Html Msg
calculationButtons route remotePages currentPage isCurrentUserAdmin currentSubPage =
    let
        calculationButtonElement =
            case route of
                Search _ _ ->
                    span

                _ ->
                    if currentPage == Nothing then
                        span

                    else
                        a

        showVotersHash =
            currentSubPage
                |> Maybe.map (\subPage -> createBrowseWithVotersPath subPage.generation subPage.letter)
                |> Maybe.withDefault createDefaultPath

        showRankingsHash =
            currentSubPage
                |> Maybe.map (\subPage -> createBrowseWithRankingsPath subPage.generation subPage.letter)
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
            [ text "Voters" ]
        , calculationButtonElement
            [ classList
                [ ( "show-rankings", True )
                , ( "button", True )
                ]
            , href showRankingsHash
            ]
            [ text "Rankings" ]
        , copyrightButton route currentSubPage
        , homeButton
        , lockButton route currentPage isCurrentUserAdmin
        ]


rankingsTable : ApplicationState -> Maybe Page -> Bool -> Html Msg
rankingsTable state currentPage isCurrentUserAdmin =
    case state.currentRoute of
        Browse BWithPokemonRankings _ ->
            let
                rankingsToShow =
                    calculatePokemonVotes state
                        |> List.sortBy .totalVotes
                        |> List.reverse

                winnerRating =
                    List.head rankingsToShow
                        |> Maybe.map .totalVotes
                        |> Maybe.withDefault 0

                isWinner : Int -> Bool
                isWinner pokemonId =
                    currentPage
                        |> Maybe.map (\page -> page.winnerId == Just pokemonId)
                        |> Maybe.withDefault False

                winnerBadge : Int -> List (Html Msg)
                winnerBadge pokemonId =
                    if isWinner pokemonId then
                        [ img
                            [ class "ribbon"
                            , src "/images/ribbon.png"
                            ]
                            []
                        ]

                    else
                        []

                winButtonCell : Int -> String -> List (Html Msg)
                winButtonCell pokemonId name =
                    if not isCurrentUserAdmin then
                        []

                    else
                        currentPage
                            |> Maybe.Extra.unwrap
                                -- defaultValue
                                []
                                -- mapFunction
                                (\page ->
                                    [ td []
                                        [ button
                                            [ onClick (WinnerElected page (PokeWinner pokemonId name))
                                            , classList
                                                [ ( "elect-button", True )
                                                , ( "winner", page.winnerId == Just pokemonId )
                                                ]
                                            ]
                                            [ text "win" ]
                                        ]
                                    ]
                                )
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
                                ([ td [] ([ text r.name ] ++ winnerBadge r.pokemonId)
                                 , td [] [ text (toString r.totalVotes) ]
                                 ]
                                    ++ winButtonCell r.pokemonId r.name
                                )
                        )
                        rankingsToShow
                ]

        _ ->
            span [] []


votersTable : ApplicationState -> Html Msg
votersTable state =
    case state.currentRoute of
        Browse BWithPeopleVotes _ ->
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

copyRightTableHtml : Html Msg
copyRightTableHtml =
    div
        [ class "copyright-table-wrapper" ]
        [ div
            [ class "copyright-table" ]
            [ p
                []
                [ a
                    [ href "https://github.com/ruittenb/sprintname-voting-booth"
                    , target "_blank"
                    , rel "noopener"
                    ]
                    [ text "Pokémon Sprint Name Voting Booth" ]
                , br [] []
                , text " © 2017-2022 René Uittenbogaard"
                ]
            , p
                []
                [ text "Pokémon © 1995-2022 Nintendo/ Creatures Inc./ Game Freak Inc. "
                , text "Pokémon and Pokémon character names are trademarks of Nintendo."
                ]
            , p
                []
                [ text "Pokémon descriptions from "
                , a
                    [ href "https://bulbapedia.bulbagarden.net/wiki/Main_Page"
                    , target "_blank"
                    , rel "noopener"
                    ]
                    [ text "Bulbapedia" ]
                , text ", The Original Pokémon Wiki"
                ]
            , p
                []
                [ text "The Fakemon presented here are"
                , br [] []
                , text "© ReallyDarkandWindie "
                , a
                    [ href "https://www.deviantart.com/reallydarkandwindie/gallery"
                    , target "_blank"
                    , rel "noopener"
                    ] [ text "DeviantArt" ]
                , br [] []
                , text " Fakemon descriptions: "
                , img [ src "icons/creativecommons.svg" ] []
                , text " "
                , a
                    [ href "https://darkandwindiefakemon.fandom.com/wiki/DarkandWindie_Fakemon_Wiki"
                    , target "_blank"
                    , rel "noopener"
                    ] [ text "Fakemon Wiki" ]
                ]
            ]
        ]


copyrightTable : ApplicationState -> Html Msg
copyrightTable state =
    case state.currentRoute of
        Browse BWithCopyright _ ->
            copyRightTableHtml

        Search SWithCopyright _ ->
            copyRightTableHtml

        _ ->
            span [] []


tableMask : Route -> Html Msg
tableMask route =
    let
        maskHtml =
            div
                [ class "mask"
                , onClick CloseMaskClicked
                ]
                []
    in
    case route of
        Browse BWithPokemonRankings _ ->
            maskHtml

        Browse BWithPeopleVotes _ ->
            maskHtml

        Browse BWithCopyright _ ->
            maskHtml

        Search SWithCopyright _ ->
            maskHtml

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
        [ pokeGenerationButtons
            state.currentRoute
            state.pokedex
            state.subPage
        , searchBox
            state.currentRoute
            state.query
        , rdawGenerationButtons
            state.currentRoute
            state.pokedex
            state.subPage
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
        , copyrightTable
            state
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
