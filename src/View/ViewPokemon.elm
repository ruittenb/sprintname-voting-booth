module ViewPokemon exposing (..)

import List exposing (..)
import Maybe exposing (..)
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


ratingNode : UserRating -> Html Msg
ratingNode rating =
    let
        star =
            span [ class "star" ] []

        userTitle =
            rating.userName ++ ": " ++ toString rating.rating
    in
        span [ title userTitle ] <|
            List.repeat rating.rating star


pokemonRatings : List UserRating -> Html Msg
pokemonRatings ratings =
    div [ class "rating-nodes" ] <| List.map ratingNode ratings


extractOnePokemonFromRatings : List UserRatings -> Pokemon -> List UserRating
extractOnePokemonFromRatings ratings pokemon =
    List.map
        (\r ->
            { userName = r.userName
            , color = r.color
            , rating =
                String.slice pokemon.number (pokemon.number + 1) r.ratings
                    |> String.toInt
                    |> Result.withDefault 0
            }
        )
        ratings


pokemonTile : List UserRatings -> CurrentUserName -> Pokemon -> Html Msg
pokemonTile ratings currentUser pokemon =
    let
        lighthouseData =
            { name = "pokemon", title = pokemon.name }

        onePokemonRatings =
            extractOnePokemonFromRatings ratings pokemon

        ownRatings =
            case currentUser of
                Nothing ->
                    []

                Just simpleUserName ->
                    List.filter (\p -> (==) simpleUserName p.userName) onePokemonRatings

        otherRatings =
            case currentUser of
                Nothing ->
                    onePokemonRatings

                Just simpleUserName ->
                    List.filter (\p -> (/=) simpleUserName p.userName) onePokemonRatings
    in
        div [ class "poketile" ]
            [ p []
                [ text <| toString pokemon.number
                , linkTo pokemon.url <| text pokemon.name
                ]
            , div [ class "pokemon-image-square" ]
                [ linkToLighthouse pokemon.image lighthouseData <| pokemonImg pokemon.image
                ]
            , pokemonRatings onePokemonRatings
            , rateWidget
            ]


pokemonTiles : List Pokemon -> List UserRatings -> CurrentUserName -> List (Html Msg)
pokemonTiles pokelist ratings currentUser =
    List.map (pokemonTile ratings currentUser) pokelist


pokemonCanvas : ApplicationState -> Html Msg
pokemonCanvas state =
    let
        pokeList =
            filterPokedex state.pokedex state.generation state.letter
    in
        div [ class "pokecanvas" ] <| pokemonTiles pokeList state.ratings state.user
