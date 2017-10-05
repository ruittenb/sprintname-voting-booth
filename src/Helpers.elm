module Helpers exposing (filterPokedex)

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
