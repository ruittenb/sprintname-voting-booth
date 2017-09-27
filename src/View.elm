module View exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Material
import Material.Scheme
import Material.Table as Table
import Material.Button as Button
import Material.Options as Options exposing (css)
import Material.Typography as Typo
import Material.Elevation as Elevation
import Model exposing (..)
import Msgs exposing (Msg)


view : model -> Html Msg
view model =
    h1 []
        [ h1 [] [ text "Generation III" ]
        , div [ id "thumbnails" ]
            [ img [ src "http://elm-in-action.com/1.jpeg" ] []
            , img [ src "http://elm-in-action.com/2.jpeg" ] []
            , img [ src "http://elm-in-action.com/3.jpeg" ] []
            ]
        ]
