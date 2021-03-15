module Helpers.Pokemon exposing
    ( extractOnePokemonFromRatingString
    , extractOneUserFromRating
    , extractOneUserFromRatings
    , filterPokedex
    , filterPokedexByPage
    , filterPokedexIfReady
    , searchPokedex
    , searchPokedexIfReady
    )

import Helpers.Authentication exposing (tryGetUserProfile)
import Models exposing (User)
import Models.Authentication exposing (AuthenticationModel)
import Models.Pokemon exposing (..)
import Models.Ratings exposing (..)
import Models.Types exposing (SubPage)
import Regex exposing (caseInsensitive, regex)
import RemoteData exposing (RemoteData(..), WebData)


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
                    List.filter (.number >> String.fromInt >> (==) query) pokedex

                else
                    List.filter (.name >> Regex.contains queryPattern) pokedex
            )


searchPokedex : RemotePokedex -> String -> List Pokemon
searchPokedex remotePokedex query =
    -- search the pokedex by regex, returns [] if anything is not loaded
    searchPokedexIfReady remotePokedex query
        |> Maybe.withDefault []


extractOnePokemonFromRatingString : String -> Int -> Int
extractOnePokemonFromRatingString ratingString pokemonId =
    String.slice pokemonId (pokemonId + 1) ratingString
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
