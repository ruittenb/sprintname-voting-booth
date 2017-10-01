module CommandsPokemon exposing (..)

import Constants exposing (..)
import Models exposing (..)
import Msgs exposing (..)


loadPokemon : number -> Pokemon
loadPokemon num =
    -- Msgs.OnLoadPokemon
    missingNo
