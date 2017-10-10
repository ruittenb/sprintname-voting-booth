module Update exposing (update)

import Set
import Regex exposing (regex, caseInsensitive)
import RemoteData exposing (WebData, RemoteData(..))
import Constants exposing (..)
import Models exposing (..)
import Msgs exposing (Msg)
import Helpers exposing (filterPokedex)
import CommandsPokemon exposing (loadPokedex)
import CommandsRatings exposing (saveRatings)


extractOneUserFromRatings : TeamRatings -> CurrentUser -> ( TeamRatings, TeamRatings )
extractOneUserFromRatings ratings currentUser =
    case currentUser of
        Nothing ->
            ( [], ratings )

        Just simpleUserName ->
            List.partition (.userName >> (==) simpleUserName) ratings


extractOnePokemonFromRatingString : String -> Int -> Int
extractOnePokemonFromRatingString ratingString pokemonNumber =
    String.slice pokemonNumber (pokemonNumber + 1) ratingString
        |> String.toInt
        |> Result.withDefault 0


update : Msg -> ApplicationState -> ( ApplicationState, Cmd Msg )
update msg oldState =
    case msg of
        Msgs.OnLoadRatings NotAsked ->
            ( oldState, Cmd.none )

        Msgs.OnLoadRatings Loading ->
            ( oldState, Cmd.none )

        Msgs.OnLoadRatings (Success ratings) ->
            let
                newState =
                    { oldState | ratings = RemoteData.succeed ratings }
            in
                ( newState, loadPokedex )

        Msgs.OnLoadRatings (Failure message) ->
            let
                newState =
                    { oldState
                        | statusMessage = toString message
                        , statusLevel = Error
                        , ratings = RemoteData.Failure message
                    }
            in
                ( newState, loadPokedex )

        Msgs.OnLoadPokedex pokedex ->
            let
                ( statusMessage, statusLevel ) =
                    case pokedex of
                        NotAsked ->
                            ( "Preparing...", Notice )

                        Loading ->
                            ( "Loading...", Notice )

                        Failure mess ->
                            ( toString mess, Error )

                        Success _ ->
                            ( "", None )

                newState =
                    { oldState
                        | pokedex = pokedex
                        , statusMessage = statusMessage
                        , statusLevel = statusLevel
                    }
            in
                ( newState, Cmd.none )

        Msgs.ChangeUser newUser ->
            let
                newState =
                    case oldState.ratings of
                        Success actualRatings ->
                            if
                                List.map .userName actualRatings
                                    |> List.member newUser
                            then
                                { oldState | user = Just newUser, statusMessage = "", statusLevel = None }
                            else
                                { oldState | statusMessage = "Unknown user", statusLevel = Error }

                        _ ->
                            oldState
            in
                ( newState, Cmd.none )

        Msgs.ChangeGeneration newGen ->
            let
                newState =
                    if List.member newGen allGenerations then
                        { oldState | generation = newGen, statusMessage = "", statusLevel = None }
                    else
                        oldState
            in
                ( newState, Cmd.none )

        Msgs.ChangeLetter newLetter ->
            let
                newState =
                    if List.member newLetter allLetters then
                        { oldState | letter = newLetter, statusMessage = "", statusLevel = None }
                    else
                        oldState
            in
                ( newState, Cmd.none )

        Msgs.ChangeVariant pokemonNumber direction ->
            let
                newState =
                    case oldState.pokedex of
                        Success pokedex ->
                            let
                                maybePokemon =
                                    List.filter (.number >> (==) pokemonNumber) pokedex
                                        |> List.head
                            in
                                case maybePokemon of
                                    Just pokemon ->
                                        let
                                            proposedNewVariant =
                                                if direction == Next then
                                                    pokemon.currentVariant + 1
                                                else
                                                    pokemon.currentVariant - 1

                                            newVariant =
                                                if proposedNewVariant < 1 then
                                                    List.length pokemon.variants
                                                else if proposedNewVariant > List.length pokemon.variants then
                                                    1
                                                else
                                                    proposedNewVariant

                                            newPokemon =
                                                { pokemon | currentVariant = newVariant }

                                            newPokedex =
                                                List.map
                                                    (\p ->
                                                        if p.number == pokemonNumber then
                                                            newPokemon
                                                        else
                                                            p
                                                    )
                                                    pokedex
                                        in
                                            { oldState | pokedex = RemoteData.succeed newPokedex }

                                    Nothing ->
                                        oldState

                        _ ->
                            oldState
            in
                ( newState, Cmd.none )

        Msgs.SearchPokemon pattern ->
            let
                newState =
                    if pattern == "" then
                        oldState
                    else
                        case oldState.pokedex of
                            Success pokedex ->
                                let
                                    patRegex =
                                        caseInsensitive (regex pattern)

                                    maybePokemon =
                                        List.filter (.name >> Regex.contains patRegex) pokedex
                                            |> List.head

                                    newState =
                                        case maybePokemon of
                                            Just pokemon ->
                                                { oldState | letter = pokemon.letter, generation = pokemon.generation }

                                            Nothing ->
                                                oldState
                                in
                                    newState

                            _ ->
                                oldState
            in
                ( newState, Cmd.none )

        Msgs.VoteForPokemon userVote ->
            case oldState.ratings of
                Success oldRatings ->
                    let
                        -- GET THE REQUIRED DATA
                        pokemonNumber =
                            userVote.pokemonNumber

                        -- extract one user
                        ( oldCurrentUserRatings, otherUserRatings ) =
                            extractOneUserFromRatings oldRatings oldState.user

                        -- extract user rating string, or create one
                        oldUserRatingString =
                            case List.head oldCurrentUserRatings of
                                Nothing ->
                                    String.repeat totalPokemon "0"

                                Just actualUserRatings ->
                                    actualUserRatings.ratings

                        -- find new vote. If the same as old vote, clear it
                        newPokeRating =
                            if oldPokeRating == userVote.vote then
                                0
                            else
                                userVote.vote

                        -- CHECK IF VOTE HAS NOT ALREADY BEEN CAST
                        pokeList =
                            filterPokedex oldState.pokedex oldState.generation oldState.letter

                        -- extract one pokemon rating
                        oldPokeRating =
                            extractOnePokemonFromRatingString oldUserRatingString pokemonNumber

                        otherPokemonRatings =
                            Set.fromList <|
                                List.map (.number >> extractOnePokemonFromRatingString oldUserRatingString) pokeList

                        -- REGISTER NEW VOTE
                        ( newState, newCmd ) =
                            if newPokeRating == 0 || not (Set.member newPokeRating otherPokemonRatings) then
                                case List.head oldCurrentUserRatings of
                                    Nothing ->
                                        ( oldState, Cmd.none )

                                    Just actualUserRatings ->
                                        let
                                            -- store new vote in rating string
                                            newUserRatingString =
                                                (String.slice 0 pokemonNumber oldUserRatingString)
                                                    ++ (toString newPokeRating)
                                                    ++ (String.slice (pokemonNumber + 1) (totalPokemon + 1) oldUserRatingString)

                                            -- insert into new state
                                            newCurrentUserRatings =
                                                { actualUserRatings | ratings = newUserRatingString }

                                            newStateRatings =
                                                newCurrentUserRatings :: otherUserRatings
                                        in
                                            ( { oldState | ratings = Success newStateRatings, statusMessage = "" }
                                            , saveRatings newCurrentUserRatings
                                            )
                            else
                                ( { oldState
                                    | statusMessage = "You already voted " ++ toString newPokeRating ++ " in this category"
                                    , statusLevel = Warning
                                  }
                                , Cmd.none
                                )
                    in
                        ( newState, newCmd )

                _ ->
                    ( oldState, Cmd.none )

        Msgs.OnSaveRatings NotAsked ->
            ( oldState, Cmd.none )

        Msgs.OnSaveRatings Loading ->
            ( oldState, Cmd.none )

        Msgs.OnSaveRatings (Success ratings) ->
            ( oldState, Cmd.none )

        Msgs.OnSaveRatings (Failure message) ->
            let
                newState =
                    { oldState | statusMessage = toString message, statusLevel = Error }
            in
                ( newState, Cmd.none )
