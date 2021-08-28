module Helpers.Pokemon
    exposing
        ( filterPokedexByPage
        , filterPokedexByGeneration
        , filterPokedexIfReady
        , filterPokedex
        , searchPokedexIfReady
        , searchPokedex
        , extractOnePokemonFromRatingString
        , extractOneUserFromRatings
        , extractOneUserFromRating
        )

import Regex exposing (regex, caseInsensitive)
import RemoteData exposing (WebData, RemoteData(..))
import Models exposing (User)
import Models.Authentication exposing (AuthenticationModel)
import Models.Types exposing (SubPage)
import Models.Pokemon exposing (..)
import Models.Ratings exposing (..)
import Helpers.Authentication exposing (tryGetUserProfile)


isNumeric : String -> Bool
isNumeric str =
    Regex.contains (regex "^[0-9]+$") str


filterPokedexByPage : RemotePokedex -> String -> Char -> Maybe (List Pokemon)
filterPokedexByPage remotePokedex generation letter =
    -- filters the pokedex by SubPage (generation and letter)
    RemoteData.toMaybe remotePokedex
        |> Maybe.map
            (\pokedex ->
                pokedex
                    |> List.filter (.generation >> (==) generation)
                    |> List.filter (.letter >> (==) letter)
                    |> List.sortBy .name
            )

filterPokedexByGeneration : RemotePokedex -> String -> Maybe (List Pokemon)
filterPokedexByGeneration remotePokedex generation =
    -- filters the pokedex by generation
    RemoteData.toMaybe remotePokedex
        |> Maybe.map
            (\pokedex ->
                pokedex
                    |> List.filter (.generation >> (==) generation)
            )



filterPokedexIfReady : RemotePokedex -> Maybe SubPage -> Maybe (List Pokemon)
filterPokedexIfReady remotePokedex maybeSubPage =
    -- filters the pokedex by (Maybe SubPage), returns Nothing if anything is not loaded
    maybeSubPage
        |> Maybe.andThen
            (\subPage ->
                filterPokedexByPage remotePokedex subPage.generation subPage.letter
            )


filterPokedex : RemotePokedex -> Maybe SubPage -> List Pokemon
filterPokedex remotePokedex maybeSubPage =
    -- filters the pokedex by (Maybe SubPage), returns [] if anything is not loaded
    filterPokedexIfReady remotePokedex maybeSubPage
        |> Maybe.withDefault []


searchPokedexIfReady : RemotePokedex -> String -> Maybe (List Pokemon)
searchPokedexIfReady remotePokedex query =
    -- search the pokedex by regex, returns Nothing if anything is not loaded
    RemoteData.toMaybe remotePokedex
        |> Maybe.map
            (\pokedex ->
                let
                    queryPattern =
                        caseInsensitive (regex query)
                in
                    if isNumeric query then
                        List.filter (.number >> toString >> (==) query) pokedex
                    else
                        List.filter (.name >> Regex.contains queryPattern) pokedex
            )


searchPokedex : RemotePokedex -> String -> List Pokemon
searchPokedex remotePokedex query =
    -- search the pokedex by regex, returns [] if anything is not loaded
    searchPokedexIfReady remotePokedex query
        |> Maybe.withDefault []


extractOnePokemonFromRatingString : String -> Int -> Int
extractOnePokemonFromRatingString ratingString pokemonNumber =
    String.slice pokemonNumber (pokemonNumber + 1) ratingString
        |> String.toInt
        |> Result.withDefault 0


extractOneUserFromRatings : TeamRatings -> User -> ( TeamRatings, TeamRatings )
extractOneUserFromRatings ratings currentUser =
    case currentUser of
        Nothing ->
            ( [], ratings )

        Just simpleUserName ->
            List.partition (.userName >> (==) simpleUserName) ratings


extractOneUserFromRating : TeamRating -> User -> ( TeamRating, TeamRating )
extractOneUserFromRating ratings currentUser =
    case currentUser of
        Nothing ->
            ( [], ratings )

        Just simpleUserName ->
            List.partition (.userName >> (==) simpleUserName) ratings
