module Helpers exposing (capitalized, generationRange, generationOf, filterPokedex)

import Maybe
import Array exposing (Array)
import Char exposing (toUpper)
import String exposing (cons, uncons)
import RemoteData exposing (WebData)
import Models exposing (..)
import Constants exposing (..)


capitalized : String -> String
capitalized name =
    case String.uncons name of
        Nothing ->
            name

        Just ( initial, rest ) ->
            String.cons (Char.toUpper initial) rest


generationRange : Int -> List Int
generationRange gen =
    case Array.get gen generations of
        Just ( min, max ) ->
            List.range min max

        Nothing ->
            []


generationOf : Int -> Int
generationOf number =
    let
        indexedGenerations : List ( Int, GenerationTuple )
        indexedGenerations =
            Array.toIndexedList generations

        getIndexIfBetween : ( Int, GenerationTuple ) -> Maybe Int
        getIndexIfBetween indexedGenerationTuple =
            let
                ( index, generationTuple ) =
                    indexedGenerationTuple

                ( min, max ) =
                    generationTuple
            in
                if min <= number && number <= max then
                    Just index
                else
                    Nothing
    in
        List.filterMap getIndexIfBetween
            indexedGenerations
            |> List.head
            |> Maybe.withDefault 0


firstLetterIs : Char -> String -> Bool
firstLetterIs letter word =
    case String.uncons word of
        Just ( firstLetter, rest ) ->
            firstLetter == letter

        Nothing ->
            False


filterPokedex : Pokedex -> Int -> Char -> List Pokemon
filterPokedex pokedex generation letter =
    let
        currentGeneration =
            case Array.get generation generations of
                Just ( min, max ) ->
                    Array.toList <| Array.slice min max pokedex

                _ ->
                    []

        currentGenerationAndLetter =
            List.filter RemoteData.isSuccess currentGeneration
                |> List.map (RemoteData.withDefault missingNo)
                |> List.filter (.name >> firstLetterIs letter)
    in
        List.sortBy .name currentGenerationAndLetter
