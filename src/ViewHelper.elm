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

import Msgs exposing (Msg)


romanNumeral : Int -> String
romanNumeral i =
    case i of
        1 ->
            "I"

        2 ->
            "II"

        3 ->
            "III"

        4 ->
            "IV"

        5 ->
            "V"

        6 ->
            "VI"

        7 ->
            "VII"

        _ ->
            "?"


heading : Int -> Html Msg
heading gen =
    let
        romanGen =
            romanNumeral gen

        headingText =
            "Generatie " ++ romanGen
    in
        h1 [] [ text headingText ]


linkTo : String -> Html Msg -> Html Msg
linkTo url content =
    a [ href url ] [ content ]


rateWidget : Html Msg
rateWidget =
    select
        [ name "rating"
        , class "rating"
        ]
        -- workaround for value=""; see https://github.com/elm-lang/html/issues/91
        [ option [ Html.Attributes.attribute "value" "", selected True ] [ text "0" ]
        , option [ value "1" ] [ text "1" ]
        , option [ value "2" ] [ text "2" ]
        , option [ value "3" ] [ text "3" ]
        ]
