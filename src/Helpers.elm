module Helpers exposing (filterPokedex, searchPokedex)

import Regex exposing (regex, caseInsensitive)
import RemoteData exposing (WebData, RemoteData(..))
import Models exposing (..)


filterPokedex : WebData Pokedex -> Int -> Char -> List Pokemon
filterPokedex pokedex generation letter =
    let
        selection =
            case pokedex of
                Success pokeList ->
                    List.filter (.letter >> (==) letter) <|
                        List.filter (.generation >> (==) generation) pokeList

                _ ->
                    []
    in
        List.sortBy .name selection


searchPokedex : WebData Pokedex -> String -> List Pokemon
searchPokedex pokedex query =
    case pokedex of
        Success pokedex ->
            let
                justNumber =
                    regex "^[0-9]+$"

                pattern =
                    caseInsensitive (regex query)

                pokeList =
                    if Regex.contains justNumber query then
                        -- query by number
                        List.filter (.number >> toString >> (==) query) pokedex
                    else
                        -- query by regex
                        List.filter (.name >> Regex.contains pattern) pokedex
            in
                pokeList

        _ ->
            []
