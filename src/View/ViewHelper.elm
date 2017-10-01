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
