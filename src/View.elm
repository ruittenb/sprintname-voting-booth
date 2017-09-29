module View exposing (..)

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

import ViewApplication exposing (..)
import ViewHelper exposing (..)
import Helpers exposing (..)
import Models exposing (..)
import Msgs exposing (Msg)


pokemonImg : String -> Html Msg
pokemonImg imageUrl =
    img
        [ src imageUrl
        , class "pokemon-image"
        ]
        []



{-
   pokemonVotes : List UserVote -> Html Msg
   pokemonVotes userVotes =
       div [ class "vote-nodes" ] <| List.map voteNode userVotes
-}


pokemonRow : Pokemon -> Html Msg
pokemonRow pokemon =
    let
        lighthouseData =
            { name = "pokemon", title = pokemon.name }
    in
        tr []
            [ td [] [ text <| toString pokemon.number ]
            , td [] [ linkTo pokemon.url <| text pokemon.name ]
            , td [] [ linkToLighthouse pokemon.image lighthouseData <| pokemonImg pokemon.image ]
            , td [] [ rateWidget ]
            ]



--            , td [] [ pokemonVotes pokemon.votes ]


pokemonRows : List Pokemon -> List (Html Msg)
pokemonRows pokelist =
    List.map pokemonRow pokelist


pokemonTable : ApplicationState -> Html Msg
pokemonTable state =
    let
        pokeList =
            filterPokedex state.pokedex state.generation state.letter
    in
        table [ class "poketable" ] <| pokemonRows pokeList


view : ApplicationState -> Html Msg
view state =
    div []
        [ heading state
        , pokemonTable state
        ]
