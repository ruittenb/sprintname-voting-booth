module ViewHelper exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)


{-
   import Material
   import Material.Scheme
   import Material.Table as Table
   import Material.Button as Button
   import Material.Options as Options exposing (css)
   import Material.Typography as Typo
   import Material.Elevation as Elevation
-}

import Models exposing (..)
import Msgs exposing (Msg)


{-| returns the number range for a generation.
-}
numberRangeOf : Int -> List Int
numberRangeOf gen =
    case gen of
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
    if number < 152 then
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


pokeImageName : String -> String
pokeImageName pokemonName =
    case pokemonName of
        "deoxys" ->
            "deoxys-normal"

        _ ->
            pokemonName


pokeImageUrl : String -> String
pokeImageUrl pokemonName =
    "https://img.pokemondb.net/artwork/" ++ (pokeImageName pokemonName) ++ ".jpg"
