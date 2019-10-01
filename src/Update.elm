module Update exposing (update)

import List.Extra exposing (replaceIf)
import RemoteData exposing (WebData, RemoteData(..))
import Navigation exposing (newUrl)
import Control exposing (update)
import Constants exposing (maintenanceApology)
import Models exposing (..)
import Models.Types exposing (..)
import Msgs exposing (Msg(..))
import Routing exposing (createSearchPath, createBrowsePath)
import Commands exposing (andThenCmd)
import Commands.Database
    exposing
        ( firebaseInit
        , firebaseLoginWithJwtToken
        , firebaseLoginWithFirebaseToken
        , firebaseLogout
        )
import Helpers exposing (setStatusMessage, clearStatusMessage)
import Helpers.Authentication exposing (getUserNameForAuthModel)
import Helpers.Pokemon
    exposing
        ( extractOneUserFromRatings
        , extractOnePokemonFromRatingString
        )
import Update.Authentication exposing (updateAuthWithProfile, updateAuthWithNoProfile)
import Update.Settings exposing (updateMaintenanceMode)
import Update.Ratings exposing (updateVoteForPokemon)
import Update.Pages exposing (updatePageLockState, updatePageWithWinner)
import Update.Pokemon
    exposing
        ( updateOnLoadPokedex
        , updateChangeGenerationAndLetter
        , updateSearchPokemon
        , updateChangeVariant
        )


update : Msg -> ApplicationState -> ( ApplicationState, Cmd Msg )
update msg oldState =
    case msg of
        AuthenticationReceived (Ok credentials) ->
            updateAuthWithProfile oldState credentials
                |> andThenCmd (firebaseLoginWithJwtToken credentials.idToken)

        AuthenticationReceived (Err error) ->
            updateAuthWithNoProfile oldState (Just error)
                |> andThenCmd firebaseLogout

        AuthenticationFailed reason ->
            updateAuthWithNoProfile oldState (Just reason)
                |> andThenCmd firebaseLogout

        AuthenticationLogoutClicked ->
            updateAuthWithNoProfile oldState Nothing
                |> andThenCmd firebaseLogout

        AuthenticationLoginClicked ->
            ( oldState
            , oldState.authModel.showLock oldState.authModel.lockParameters
            )

        FirebaseLoginFailed reason ->
            updateAuthWithNoProfile oldState (Just reason)
                |> andThenCmd firebaseLogout

        SettingsLoaded (Success settings) ->
            let
                newState =
                    { oldState | settings = RemoteData.succeed settings }

                newTuple =
                    if not settings.maintenanceMode then
                        ( newState, Cmd.none )
                            |> clearStatusMessage
                    else
                        ( newState, Cmd.none )
                            |> setStatusMessage Maintenance maintenanceApology
            in
                newTuple

        SettingsLoaded (Failure message) ->
            let
                newState =
                    { oldState
                        | ratings = RemoteData.Failure message
                    }
            in
                ( newState, Cmd.none )
                    |> setStatusMessage Error (toString message)

        SettingsLoaded _ ->
            ( oldState, Cmd.none )

        PagesLoaded (Success pages) ->
            let
                newState =
                    { oldState | pages = RemoteData.succeed pages }
            in
                ( newState, Cmd.none )

        PagesLoaded (Failure message) ->
            let
                newState =
                    { oldState
                        | pages = RemoteData.Failure message
                    }
            in
                ( newState, Cmd.none )
                    |> setStatusMessage Error (toString message)

        PagesLoaded _ ->
            ( oldState, Cmd.none )

        PageLoaded (Success page) ->
            let
                newPages =
                    RemoteData.map
                        (replaceIf (.id >> (==) page.id) page)
                        oldState.pages

                newState =
                    { oldState | pages = newPages }
            in
                ( newState, Cmd.none )

        PageLoaded (Failure message) ->
            ( oldState, Cmd.none )
                |> setStatusMessage Error (toString message)

        PageLoaded _ ->
            ( oldState, Cmd.none )

        TeamRatingsLoaded (Success ratings) ->
            let
                newRatings =
                    RemoteData.succeed ratings

                userName =
                    getUserNameForAuthModel newRatings oldState.authModel

                newState =
                    { oldState | ratings = newRatings, currentUser = userName }
            in
                ( newState, Cmd.none )

        TeamRatingsLoaded (Failure message) ->
            let
                newState =
                    { oldState
                        | ratings = RemoteData.Failure message
                    }
            in
                ( newState, Cmd.none )
                    |> setStatusMessage Error (toString message)

        TeamRatingsLoaded _ ->
            ( oldState, Cmd.none )

        UserRatingsLoaded (Success userRatings) ->
            let
                newRatings =
                    RemoteData.map
                        (replaceIf (.id >> (==) userRatings.id) userRatings)
                        oldState.ratings

                newState =
                    { oldState | ratings = newRatings }
            in
                ( newState, Cmd.none )

        UserRatingsLoaded _ ->
            ( oldState, Cmd.none )

        PokedexLoaded pokedex ->
            updateOnLoadPokedex oldState pokedex

        UrlChanged (Just newRoute) ->
            case newRoute of
                Search query ->
                    updateSearchPokemon oldState query

                _ ->
                    updateChangeGenerationAndLetter oldState newRoute

        UrlChanged Nothing ->
            ( oldState, Cmd.none )

        CloseMaskClicked ->
            let
                browseSubpage =
                    Browse
                        { generation = oldState.generation
                        , letter = oldState.letter
                        }
            in
                ( { oldState | currentRoute = browseSubpage }
                , newUrl <|
                    createBrowsePath oldState.generation oldState.letter
                )

        PageLockClicked page ->
            updatePageLockState oldState page

        WinnerElected page winner ->
            updatePageWithWinner oldState page winner

        MaintenanceModeClicked ->
            updateMaintenanceMode oldState

        VariantChanged pokemonNumber direction ->
            updateChangeVariant oldState pokemonNumber direction

        SearchPokemon query ->
            updateSearchPokemon oldState query
                |> andThenCmd (newUrl <| createSearchPath query)

        DebounceSearchPokemon debMsg ->
            Control.update
                (\s -> { oldState | debounceState = s })
                oldState.debounceState
                debMsg

        PokemonVoteCast userVote ->
            updateVoteForPokemon oldState userVote

        UserRatingsSaved (Failure message) ->
            ( oldState, Cmd.none )
                |> setStatusMessage Error (toString message)

        UserRatingsSaved _ ->
            ( oldState, Cmd.none )

        Tick time ->
            if Maybe.map ((>) time) oldState.statusExpiryTime == Just True then
                ( oldState, Cmd.none )
                    |> clearStatusMessage
            else
                ( oldState, Cmd.none )

        StatusMessageExpiryTimeReceived time ->
            let
                newState =
                    { oldState | statusExpiryTime = Just time }
            in
                ( newState, Cmd.none )
