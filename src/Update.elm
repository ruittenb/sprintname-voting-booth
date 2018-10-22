module Update exposing (update)

import List.Extra exposing (replaceIf)
import RemoteData exposing (WebData, RemoteData(..))
import Navigation exposing (newUrl)
import Control exposing (update)
import Constants exposing (searchPathSegment)
import Models exposing (..)
import Models.Types exposing (..)
import Msgs exposing (Msg(..))
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

        TeamRatingsLoaded NotAsked ->
            ( oldState, Cmd.none )

        TeamRatingsLoaded Loading ->
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
                        | statusMessage = toString message
                        , statusLevel = Error
                        , ratings = RemoteData.Failure message
                    }
            in
                ( newState, Cmd.none )

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

                Browse newSubpage ->
                    updateChangeGenerationAndLetter oldState newSubpage.generation newSubpage.letter

                BrowseWithPeopleVotes newSubpage ->
                    updateChangeGenerationAndLetter oldState newSubpage.generation newSubpage.letter

                BrowseWithPokemonRankings newSubpage ->
                    updateChangeGenerationAndLetter oldState newSubpage.generation newSubpage.letter

        UrlChanged Nothing ->
            ( oldState, Cmd.none )

        VariantChanged pokemonNumber direction ->
            updateChangeVariant oldState pokemonNumber direction

        SearchPokemon query ->
            updateSearchPokemon oldState query
                |> andThenCmd (newUrl <| "#/" ++ searchPathSegment ++ "/" ++ query)

        DebounceSearchPokemon debMsg ->
            Control.update
                (\s -> { oldState | debounceState = s })
                oldState.debounceState
                debMsg

        PokemonVoteCast userVote ->
            updateVoteForPokemon oldState userVote

        UserRatingsSaved NotAsked ->
            ( oldState, Cmd.none )

        UserRatingsSaved Loading ->
            ( oldState, Cmd.none )

        UserRatingsSaved (Success ratings) ->
            ( oldState, Cmd.none )

        UserRatingsSaved (Failure message) ->
            let
                newState =
                    { oldState | statusMessage = toString message, statusLevel = Error }
            in
                ( newState, Cmd.none )

        ShowRankingsClicked ->
            ( oldState, Cmd.none )

        ShowVotersClicked ->
            ( oldState, Cmd.none )
