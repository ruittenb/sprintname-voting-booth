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
        Msgs.GenerationAndLetterChanged subpage.generation subpage.letter



-- central update function


update : Msg -> ApplicationState -> ( ApplicationState, Cmd Msg )
update msg oldState =
    case msg of
        Msgs.TeamRatingsLoaded NotAsked ->
            ( oldState, Cmd.none )

        Msgs.TeamRatingsLoaded Loading ->
            ( oldState, Cmd.none )

        Msgs.TeamRatingsLoaded (Success ratings) ->
            let
                newRatings =
                    RemoteData.succeed ratings

                userName =
                    getUserNameForAuthModel newRatings oldState.authModel

                newState =
                    { oldState | ratings = newRatings, user = userName }
            in
                ( newState, Cmd.none )

        Msgs.TeamRatingsLoaded (Failure message) ->
            let
                newState =
                    { oldState
                        | statusMessage = toString message
                        , statusLevel = Error
                        , ratings = RemoteData.Failure message
                    }
            in
                ( newState, Cmd.none )

        Msgs.UserRatingsLoaded (Success userRatings) ->
            let
                newRatings =
                    RemoteData.map
                        (replaceIf (.id >> (==) userRatings.id) userRatings)
                        oldState.ratings

                newState =
                    { oldState | ratings = newRatings }
            in
                ( newState, Cmd.none )

        Msgs.UserRatingsLoaded _ ->
            ( oldState, Cmd.none )

        Msgs.UserRatingsSaved NotAsked ->
            ( oldState, Cmd.none )

        Msgs.UserRatingsSaved Loading ->
            ( oldState, Cmd.none )

        Msgs.UserRatingsSaved (Success ratings) ->
            ( oldState, Cmd.none )

        Msgs.UserRatingsSaved (Failure message) ->
            let
                newState =
                    { oldState | statusMessage = toString message, statusLevel = Error }
            in
                ( newState, Cmd.none )

        Msgs.PokedexLoaded pokedex ->
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

        Msgs.GenerationChanged newGen ->
            updateChangeGenerationAndLetter oldState newGen oldState.letter

        Msgs.LetterChanged newLetter ->
            updateChangeGenerationAndLetter oldState oldState.generation newLetter

        Msgs.GenerationAndLetterChanged newGen newLetter ->
            updateChangeGenerationAndLetter oldState newGen newLetter

        Msgs.VariantChanged pokemonNumber direction ->
            updateChangeVariant oldState pokemonNumber direction

        Msgs.SearchPokemon pattern ->
            updateSearchPokemon oldState pattern

        Msgs.DebounceSearchPokemon debMsg ->
            Control.update
                (\s -> { oldState | debounceState = s })
                oldState.debounceState
                debMsg

        Msgs.PokemonVoteCast userVote ->
            updateVoteForPokemon oldState userVote
