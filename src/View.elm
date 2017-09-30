module View exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import ViewPokemon exposing (..)
import ViewApplication exposing (..)
import Helpers exposing (..)
import Models exposing (..)
import Msgs exposing (Msg)


view : ApplicationState -> Html Msg
view state =
    div []
        [ heading state
        , pokemonCanvas state
        ]
