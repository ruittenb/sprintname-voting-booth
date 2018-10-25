module View exposing (view)

import Html exposing (Html, div)
import View.Application exposing (heading, title)
import View.Pokemon exposing (pokemonCanvas)
import Models exposing (ApplicationState)
import Msgs exposing (Msg)


view : ApplicationState -> Html Msg
view state =
    div []
        [ title
        , heading state
        , pokemonCanvas state
        ]
