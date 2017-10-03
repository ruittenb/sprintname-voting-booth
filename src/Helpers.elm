module Helpers exposing (..)

import Models exposing (..)


{-| returns the generation number for the pokemon number
I. 1-151
II. 152-251
III. 252-386
IV. 387-493
V. 494-649
VI. 650-721
VII. 722-802
-}
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


{-| returns the number range for a generation.
-}
numberRangeOf : Int -> List Int
numberRangeOf gen =
    case gen of
        0 ->
            [ 0 ]

        1 ->
            List.range 1 151

        2 ->
            List.range 152 251

        3 ->
            List.range 252 386

        4 ->
            List.range 387 493

        5 ->
            List.range 494 649

        6 ->
            List.range 650 721

        7 ->
            List.range 722 802

        _ ->
            []


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
        List.sortBy .name currentGenerationAndLetter
