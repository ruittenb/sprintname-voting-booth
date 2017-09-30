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


pokemonRow : List UserRatings -> CurrentUserName -> Pokemon -> Html Msg
pokemonRow ratings currentUser pokemon =
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
        tr []
            [ td [] [ text <| toString pokemon.number ]
            , td [] [ linkTo pokemon.url <| text pokemon.name ]
            , td [] [ linkToLighthouse pokemon.image lighthouseData <| pokemonImg pokemon.image ]
            , td [] [ pokemonRatings onePokemonRatings ]
            , td [] [ rateWidget ]
            ]


pokemonRows : List Pokemon -> List UserRatings -> CurrentUserName -> List (Html Msg)
pokemonRows pokelist ratings currentUser =
    List.map (pokemonRow ratings currentUser) pokelist


pokemonTable : ApplicationState -> Html Msg
pokemonTable state =
    let
        pokeList =
            filterPokedex state.pokedex state.generation state.letter
    in
        table [ class "poketable" ] <| pokemonRows pokeList state.ratings state.user
