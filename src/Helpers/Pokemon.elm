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
slicePokedex pokedex generation letter =
    RemoteData.toMaybe pokedex
        |> Maybe.map
            (\pokeList ->
                pokeList
                    |> List.filter (.letter >> (==) letter)
                    |> List.filter (.generation >> (==) generation)
            )
        |> Maybe.withDefault []


filterPokedex : RemotePokedex -> Maybe SubPage -> List Pokemon
filterPokedex pokedex maybeSubPage =
    let
        selection =
            Maybe.map2
                (\pokeList subPage ->
                    pokeList
                        |> List.filter (.letter >> (==) subPage.letter)
                        |> List.filter (.generation >> (==) subPage.generation)
                )
                (RemoteData.toMaybe pokedex)
                maybeSubPage
                |> Maybe.withDefault []
    in
        List.sortBy .name selection


searchPokedex : RemotePokedex -> String -> List Pokemon
searchPokedex remotePokedex query =
    remotePokedex
        |> RemoteData.map
            (\pokedex ->
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
