module Update exposing (update, dissectLocationHash, hashToMsg)

import Char
import List
import List.Extra exposing (replaceIf)
import Navigation exposing (Location)
import RemoteData exposing (WebData, RemoteData(..))
import Authentication exposing (update)
import Control exposing (update)
import Models exposing (..)
import Models.Types exposing (..)
import Msgs exposing (Msg)
import Helpers exposing (getUserNameForAuthModel)
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
        Msgs.ChangeGenerationAndLetter subpage.generation subpage.letter



-- central update function


update : Msg -> ApplicationState -> ( ApplicationState, Cmd Msg )
update msg oldState =
    case msg of
        Msgs.OnLoadTeamRatings NotAsked ->
            ( oldState, Cmd.none )

        Msgs.OnLoadTeamRatings Loading ->
            ( oldState, Cmd.none )

        Msgs.OnLoadTeamRatings (Success ratings) ->
            let
                newRatings =
                    RemoteData.succeed ratings

                userName =
                    getUserNameForAuthModel newRatings oldState.authModel

                newState =
                    { oldState | ratings = newRatings, user = userName }
            in
                ( newState, Cmd.none )

        Msgs.OnLoadTeamRatings (Failure message) ->
            let
                newState =
                    { oldState
                        | statusMessage = toString message
                        , statusLevel = Error
                        , ratings = RemoteData.Failure message
                    }
            in
                ( newState, Cmd.none )

        Msgs.OnLoadUserRatings (Success userRatings) ->
            let
                newRatings =
                    RemoteData.map
                        (replaceIf (.id >> (==) userRatings.id) userRatings)
                        oldState.ratings

                newState =
                    { oldState | ratings = newRatings }
            in
                ( newState, Cmd.none )

        Msgs.OnLoadUserRatings _ ->
            ( oldState, Cmd.none )

        Msgs.OnSaveUserRatings NotAsked ->
            ( oldState, Cmd.none )

        Msgs.OnSaveUserRatings Loading ->
            ( oldState, Cmd.none )

        Msgs.OnSaveUserRatings (Success ratings) ->
            ( oldState, Cmd.none )

        Msgs.OnSaveUserRatings (Failure message) ->
            let
                newState =
                    { oldState | statusMessage = toString message, statusLevel = Error }
            in
                ( newState, Cmd.none )

        Msgs.OnLoadPokedex pokedex ->
            updateOnLoadPokedex oldState pokedex

        Msgs.AuthenticationMsg authMsg ->
            let
                ( authModel, cmd ) =
                    Authentication.update authMsg oldState.authModel

                newState =
                    { oldState
                        | authModel = authModel
                        , user = getUserNameForAuthModel oldState.ratings authModel
                    }
            in
                ( newState, Cmd.map Msgs.AuthenticationMsg cmd )

        Msgs.ChangeGeneration newGen ->
            updateChangeGenerationAndLetter oldState newGen oldState.letter

        Msgs.ChangeLetter newLetter ->
            updateChangeGenerationAndLetter oldState oldState.generation newLetter

        Msgs.ChangeGenerationAndLetter newGen newLetter ->
            updateChangeGenerationAndLetter oldState newGen newLetter

        Msgs.ChangeVariant pokemonNumber direction ->
            updateChangeVariant oldState pokemonNumber direction

        Msgs.SearchPokemon pattern ->
            updateSearchPokemon oldState pattern

        Msgs.DebounceSearchPokemon debMsg ->
            Control.update
                (\s -> { oldState | debounceState = s })
                oldState.debounceState
                debMsg

        Msgs.VoteForPokemon userVote ->
            updateVoteForPokemon oldState userVote
