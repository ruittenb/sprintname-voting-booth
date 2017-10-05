module Update exposing (..)

import Constants exposing (..)
import Models exposing (..)
import Helpers exposing (generationOf)
import Msgs exposing (Msg)
import RemoteData exposing (..)


-- import CommandsRatings exposing (..)


extractOneUserFromRatings : TeamRatings -> CurrentUser -> List UserRatings
extractOneUserFromRatings ratings currentUser =
    case currentUser of
        Nothing ->
            []

        Just simpleUserName ->
            List.filter (\p -> (==) simpleUserName p.userName) ratings


extractOtherUsersFromRatings : TeamRatings -> CurrentUser -> List UserRatings
extractOtherUsersFromRatings ratings currentUser =
    case currentUser of
        Nothing ->
            ratings

        Just simpleUserName ->
            List.filter (\p -> (/=) simpleUserName p.userName) ratings


update : Msg -> ApplicationState -> ( ApplicationState, Cmd Msg )
update msg oldState =
    case msg of
        Msgs.OnLoadRatings ratings ->
            let
                ( statusMessage, statusLevel ) =
                    case ratings of
                        NotAsked ->
                            ( "Preparing...", Notice )

                        Loading ->
                            ( "Loading...", Notice )

                        Success _ ->
                            ( "", None )

                        Failure mess ->
                            ( toString mess, Error )

                newState =
                    { oldState
                        | statusMessage = statusMessage
                        , statusLevel = statusLevel
                        , ratings = ratings
                    }
            in
                ( newState, Cmd.none )

        Msgs.OnLoadPokemon ( num, loadedPokemon ) ->
            let
                gen : Int
                gen =
                    generationOf num

                oldGeneration : Maybe PokeGeneration
                oldGeneration =
                    List.filter (\g -> g.generation == gen) oldState.pokedex
                        |> List.head

                oldListPokemon : List (WebData Pokemon)
                oldListPokemon =
                    Maybe.map .pokemon oldGeneration
                        |> Maybe.withDefault []

                -- there is a fundamental problem here: if Pokemon was not successfully loaded, it has no 'number' property.
                -- Therefore, it is not found; therefore, it is never replaced, even if subsequent loads load it correctly.
                -- This in turn never gets rid of the error state on the generation.
                -- The solution lies probably in storing pokemon in an array, using ranges to filter generations and indexes to store them by number.
                ( matches, strippedListPokemon ) =
                    List.partition
                        (\p ->
                            case p of
                                Success pokemon ->
                                    pokemon.number == num

                                _ ->
                                    False
                        )
                        oldListPokemon

                newListPokemon =
                    loadedPokemon :: strippedListPokemon

                newGeneration =
                    case oldGeneration of
                        Nothing ->
                            { generation = gen, pokemon = newListPokemon }

                        Just actualOldGeneration ->
                            { actualOldGeneration | pokemon = newListPokemon }

                newPokedex =
                    List.map
                        (\p ->
                            if p.generation == gen then
                                newGeneration
                            else
                                p
                        )
                        oldState.pokedex

                ( statusMessage, statusLevel ) =
                    case loadedPokemon of
                        NotAsked ->
                            ( "Preparing...", Notice )

                        Loading ->
                            ( "Loading...", Notice )

                        Failure mess ->
                            ( toString mess, Error )

                        _ ->
                            ( "", None )

                newState =
                    { oldState
                        | pokedex = newPokedex
                        , statusMessage = statusMessage
                        , statusLevel = statusLevel
                    }
            in
                ( newState, Cmd.none )

        Msgs.ChangeUser newUser ->
            let
                newState =
                    case oldState.ratings of
                        RemoteData.Success actualRatings ->
                            if
                                List.map .userName actualRatings
                                    |> List.member newUser
                            then
                                { oldState | user = Just newUser }
                            else
                                oldState

                        _ ->
                            oldState
            in
                ( newState, Cmd.none )

        Msgs.ChangeGeneration newGen ->
            let
                newState =
                    { oldState | generation = newGen }
            in
                if List.member newGen allGenerations then
                    ( newState, Cmd.none )
                else
                    ( oldState, Cmd.none )

        Msgs.ChangeLetter newLetter ->
            let
                newState =
                    { oldState | letter = newLetter }
            in
                if List.member newLetter allLetters then
                    ( newState, Cmd.none )
                else
                    ( oldState, Cmd.none )

        Msgs.VoteForPokemon userVote ->
            case oldState.ratings of
                NotAsked ->
                    ( oldState, Cmd.none )

                Loading ->
                    ( oldState, Cmd.none )

                Failure _ ->
                    ( oldState, Cmd.none )

                Success oldRatings ->
                    let
                        pokemonNumber =
                            userVote.pokemonNumber

                        -- extract one user
                        oldCurrentUserRatings =
                            extractOneUserFromRatings oldRatings oldState.user
                                |> List.head

                        -- the list of the other users
                        otherUserRatings =
                            extractOtherUsersFromRatings oldRatings oldState.user

                        -- extract user rating string, or create one
                        oldUserRatingString =
                            case oldCurrentUserRatings of
                                Nothing ->
                                    String.repeat totalPokemon "0"

                                Just actualUserRatings ->
                                    actualUserRatings.ratings

                        -- extract one pokemon rating
                        oldPokeRating =
                            String.slice pokemonNumber (pokemonNumber + 1) oldUserRatingString
                                |> String.toInt
                                |> Result.withDefault 0

                        -- find new vote. If the same as old vote, clear it
                        newPokeRating =
                            if oldPokeRating == userVote.vote then
                                0
                            else
                                userVote.vote

                        -- store new vote in rating string
                        newUserRatingString =
                            (String.slice 0 pokemonNumber oldUserRatingString)
                                ++ (toString newPokeRating)
                                ++ (String.slice (pokemonNumber + 1) (totalPokemon + 1) oldUserRatingString)

                        -- insert into new state
                        newState =
                            case oldCurrentUserRatings of
                                Nothing ->
                                    oldState

                                Just actualUserRatings ->
                                    let
                                        newCurrentUserRatings =
                                            { actualUserRatings | ratings = newUserRatingString }

                                        newStateRatings =
                                            newCurrentUserRatings :: otherUserRatings
                                    in
                                        { oldState | ratings = RemoteData.Success newStateRatings, statusMessage = "" }
                    in
                        ( newState, Cmd.none )



{-
   ( newState, saveRatings newStateRatings )
-}
