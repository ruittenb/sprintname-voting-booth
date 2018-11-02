module Update exposing (update)

import List.Extra exposing (replaceIf)
import RemoteData exposing (WebData, RemoteData(..))
import Navigation exposing (newUrl)
import Control exposing (update)
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
import Helpers
    exposing
        ( getUserNameForAuthModel
        , extractOneUserFromRatings
        , extractOnePokemonFromRatingString
        )
import Update.Authentication exposing (updateAuthWithProfile, updateAuthWithNoProfile)
import Update.Ratings exposing (updateVoteForPokemon)
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
                        | statusMessage = toString message
                        , statusLevel = Error
                        , ratings = RemoteData.Failure message
                    }
            in
                ( newState, Cmd.none )

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
            let
                newState =
                    { oldState | statusMessage = toString message, statusLevel = Error }
            in
                ( newState, Cmd.none )

        UserRatingsSaved _ ->
            ( oldState, Cmd.none )

        Tick time ->
            let
                newState =
                    if time > oldState.statusTime && oldState.statusTime /= 0 then
                        { oldState | statusMessage = "", statusLevel = None }
                    else
                        oldState
            in
                ( newState, Cmd.none )

        StatusMessageExpiryTimeReceived time ->
            let
                newState =
                    { oldState | statusTime = time }
            in
                ( newState, Cmd.none )
