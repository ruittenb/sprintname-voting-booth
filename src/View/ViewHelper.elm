module ViewHelper exposing (..)

import Models exposing (..)


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
