module Helpers.Pokemon
    exposing
        ( filterPokedex
        , searchPokedex
        , extractOnePokemonFromRatingString
        , extractOneUserFromRatings
        , extractOneUserFromRating
        )

import Regex exposing (regex, caseInsensitive)
import RemoteData exposing (WebData, RemoteData(..))
import Models exposing (User)
import Models.Authentication exposing (AuthenticationModel)
import Models.Pokemon exposing (..)
import Models.Ratings exposing (..)
import Helpers.Authentication exposing (tryGetUserProfile)


isNumeric : String -> Bool
isNumeric str =
    Regex.contains (regex "^[0-9]+$") str


filterPokedex : RemotePokedex -> Int -> Char -> List Pokemon
filterPokedex pokedex generation letter =
    let
        selection =
            case pokedex of
                Success pokeList ->
                    pokeList
                        |> List.filter (.letter >> (==) letter)
                        |> List.filter (.generation >> (==) generation)

                _ ->
                    []
    in
        List.sortBy .name selection


searchPokedex : RemotePokedex -> String -> List Pokemon
searchPokedex pokedex query =
    case pokedex of
        Success pokedex ->
            let
                queryPattern =
                    caseInsensitive (regex query)

                pokeList =
                    if isNumeric query then
                        List.filter (.number >> toString >> (==) query) pokedex
                    else
                        List.filter (.name >> Regex.contains queryPattern) pokedex
            in
                pokeList

        _ ->
            []


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

