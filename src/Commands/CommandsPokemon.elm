module CommandsPokemon exposing (..)

import Models exposing (..)
import Msgs exposing (..)


pokemonApiUrl : String
pokemonApiUrl =
    "http://pokeapi.co/api/v2/pokemon/"


loadPokemon : number -> Pokemon
loadPokemon num =
    -- Msgs.OnLoadPokemon
    missingNo
