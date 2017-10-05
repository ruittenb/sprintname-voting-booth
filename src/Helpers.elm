module Helpers exposing (capitalized, filterPokedex, generationOf)

import Array exposing (Array)
import Char exposing (toUpper)
import String exposing (cons, uncons)
import RemoteData exposing (WebData)
import Models exposing (..)


capitalized : String -> String
capitalized name =
    case String.uncons name of
        Nothing ->
            name

        Just ( initial, rest ) ->
            String.cons (Char.toUpper initial) rest


generations : Array GenerationTuple
generations =
    Array.fromList
        [ ( 0, 0 )
        , ( 1, 151 )
        , ( 152, 251 )
        , ( 252, 386 )
        , ( 387, 493 )
        , ( 494, 649 )
        , ( 650, 721 )
        , ( 722, 802 )
        ]


generationRange : Int -> List Int
generationRange gen =
    case Array.get gen generations of
        Just ( min, max ) ->
            List.range min max

        Nothing ->
            []


generationOf : Int -> Int
generationOf number =
    if number == 0 then
        0
    else if number < 152 then
        1
    else if number < 252 then
        2
    else if number < 387 then
        3
    else if number < 494 then
        4
    else if number < 650 then
        5
    else if number < 722 then
        6
    else
        7


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
