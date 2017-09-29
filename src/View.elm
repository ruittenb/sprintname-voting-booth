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


firstLetterIs : Char -> String -> Bool
firstLetterIs letter word =
    let
        firstLetter =
            String.uncons word
    in
        case firstLetter of
            Nothing ->
                False

            Just ( chopped, _ ) ->
                (==) chopped letter


filterPokedex : Int -> Char -> Pokedex -> List Pokemon
filterPokedex generation letter pokedex =
    let
        currentGeneration =
            List.head <|
                List.filter
                    (\d -> d.generation == generation)
                    pokedex

        currentGenerationAndLetter =
            case currentGeneration of
                Nothing ->
                    []

                Just pokeGeneration ->
                    List.filter (\d -> firstLetterIs letter d.name) pokeGeneration.pokemon
    in
        currentGenerationAndLetter


pokemonTable : ApplicationState -> Html Msg
pokemonTable state =
    let
        currentSubPokedex =
            filterPokedex state.generation state.letter state.pokedex
    in
        table [ class "poketable" ] <| pokemonRows currentSubPokedex


view : ApplicationState -> Html Msg
view state =
    div []
        [ heading state
        , pokemonTable state
        ]
