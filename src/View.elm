module View exposing (view)

import Html exposing (Html, div)
import ViewApplication exposing (heading)
import ViewPokemon exposing (pokemonCanvas)
import Models exposing (ApplicationState)
import Msgs exposing (Msg)


view : ApplicationState -> Html Msg
view state =
    div []
        [ heading state
        , pokemonCanvas state
        ]
