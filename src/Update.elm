module Update exposing (update, dissectLocationHash, hashToMsg)

import Char
import List
import List.Extra exposing (replaceIf)
import Navigation exposing (Location)
import RemoteData exposing (WebData, RemoteData(..))
import Control exposing (update)
import Models exposing (..)
import Models.Types exposing (..)
import Msgs exposing (Msg(..))
import Commands exposing (andThenCmd)
import Commands.Database exposing (firebaseInit, firebaseLogin, firebaseLogout)
import Helpers exposing (getUserNameForAuthModel)
import Update.Authentication exposing (updateAuthWithProfile, updateAuthWithNoProfile)
import Update.Ratings exposing (updateVoteForPokemon)
import Update.Pokemon
    exposing
        ( updateOnLoadPokedex
        , updateChangeGenerationAndLetter
        , updateSearchPokemon
        , updateChangeVariant
        )


-- helper functions specific to Update


dissectLocationHash : Location -> Subpage -> Subpage
dissectLocationHash location defaultSubpage =
    let
        ( _, hash ) =
            String.uncons location.hash
                |> Maybe.withDefault ( '#', "" )
    in
        case String.uncons hash of
            Just ( gen, letter ) ->
                { generation = Char.toCode gen - 48
                , letter =
                    String.toUpper letter
                        |> String.toList
                        |> List.head
                        |> Maybe.withDefault '_'
                }

            Nothing ->
                defaultSubpage


hashToMsg : Location -> Msg
hashToMsg location =
    let
        invalidPage =
            { generation = -1, letter = '_' }

        subpage =
            dissectLocationHash location invalidPage
    in
        Msgs.GenerationAndLetterChanged subpage.generation subpage.letter



-- central update function


update : Msg -> ApplicationState -> ( ApplicationState, Cmd Msg )
update msg oldState =
    case msg of
        AuthenticationReceived (Ok credentials) ->
            updateAuthWithProfile oldState credentials
                |> andThenCmd firebaseInit
                |> andThenCmd (firebaseLogin credentials.idToken)

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
                    { oldState | ratings = newRatings, user = userName }
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

        GenerationChanged newGen ->
            updateChangeGenerationAndLetter oldState newGen oldState.letter

        LetterChanged newLetter ->
            updateChangeGenerationAndLetter oldState oldState.generation newLetter

        GenerationAndLetterChanged newGen newLetter ->
            updateChangeGenerationAndLetter oldState newGen newLetter

        VariantChanged pokemonNumber direction ->
            updateChangeVariant oldState pokemonNumber direction

        SearchPokemon pattern ->
            updateSearchPokemon oldState pattern

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
