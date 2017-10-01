module Helpers exposing (..)

import Models exposing (..)


numberBetween : Int -> Int -> Int -> Bool
numberBetween min max value =
    if min <= value && value <= max then
        True
    else
        False


firstLetterIs : Char -> String -> Bool
firstLetterIs letter word =
    let
        firstLetter =
            String.uncons word
    in
        case firstLetter of
            Nothing ->
                False

            Just ( chopped, _ ) ->
                (==) chopped letter


filterPokedex : Pokedex -> Int -> Char -> List Pokemon
filterPokedex pokedex generation letter =
    let
        currentGeneration =
            List.head <|
                List.filter
                    (\d -> d.generation == generation)
                    pokedex

        currentGenerationAndLetter =
            case currentGeneration of
                Nothing ->
                    []

                Just pokeGeneration ->
                    List.filter (\d -> firstLetterIs letter d.name) pokeGeneration.pokemon
    in
        currentGenerationAndLetter
