module Helpers.Pokemon
    exposing
        ( filterPokedex
        , slicePokedex
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


slicePokedex : RemotePokedex -> Int -> Char -> List Pokemon
slicePokedex remotePokedex generation letter =
    RemoteData.toMaybe remotePokedex
        |> Maybe.map
            (\pokedex ->
                pokedex
                    |> List.filter (.letter >> (==) letter)
                    |> List.filter (.generation >> (==) generation)
            )
        |> Maybe.withDefault []


filterPokedex : RemotePokedex -> Maybe SubPage -> List Pokemon
filterPokedex remotePokedex maybeSubPage =
    maybeSubPage
        |> Maybe.andThen
            (\subPage ->
                RemoteData.toMaybe remotePokedex
                    |> Maybe.map
                        (\pokedex ->
                            pokedex
                                |> List.filter (.letter >> (==) subPage.letter)
                                |> List.filter (.generation >> (==) subPage.generation)
                        )
            )
        |> Maybe.withDefault []
        |> List.sortBy .name


searchPokedex : RemotePokedex -> String -> List Pokemon
searchPokedex remotePokedex query =
    remotePokedex
        |> RemoteData.map
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
        |> RemoteData.withDefault []


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
