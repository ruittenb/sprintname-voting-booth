module Commands exposing (loadAll)

import Msgs exposing (Msg)
import CommandsRatings exposing (loadRatings)
import CommandsPokemon exposing (loadPokemon)


--import CommandsPokemon exposing (loadPokemon, loadPokemonRange)


loadAll : Cmd Msg
loadAll =
    -- ( initialState, loadPokemonRange initialState.generation initialState.letter )
    --loadRatings
    loadPokemon 144
