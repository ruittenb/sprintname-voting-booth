module ViewPokemon exposing (..)

import List exposing (..)
import Maybe exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)


{-
   import Material
   import Material.Scheme
   import Material.Table as Table
   import Material.Button as Button
   import Material.Options as Options exposing (css)
   import Material.Typography as Typo
   import Material.Elevation as Elevation
-}

import Helpers exposing (..)
import Models exposing (..)
import Msgs exposing (Msg)


linkTo : String -> Html Msg -> Html Msg
linkTo url content =
    a [ href url ] [ content ]


linkToLighthouse : String -> LighthouseData -> Html Msg -> Html Msg
linkToLighthouse url lighthouseData content =
    a
        [ href url
        , Html.Attributes.attribute "data-lightbox" lighthouseData.name
        , Html.Attributes.attribute "data-title" lighthouseData.caption
        ]
        [ content ]


pokemonImg : String -> Html Msg
pokemonImg imageUrl =
    img
        [ src imageUrl
        , class "pokemon-image"
        ]
        []


voteWidget : List UserRating -> Int -> Html Msg
voteWidget ownRatings pokemonNumber =
    let
        userVote =
            { pokemonNumber = pokemonNumber
            , vote = 0
            }

        rating =
            case List.head ownRatings of
                Nothing ->
                    0

                Just ratingRecord ->
                    ratingRecord.rating
    in
        span [ class "voting-node" ]
            [ span
                [ classList
                    [ ( "star", True )
                    , ( "selected", rating > 0 )
                    ]
                , onClick (Msgs.VoteForPokemon { userVote | vote = 1 })
                ]
                []
            , span
                [ classList
                    [ ( "star", True )
                    , ( "selected", rating > 1 )
                    ]
                , onClick (Msgs.VoteForPokemon { userVote | vote = 2 })
                ]
                []
            , span
                [ classList
                    [ ( "star", True )
                    , ( "selected", rating > 2 )
                    ]
                , onClick (Msgs.VoteForPokemon { userVote | vote = 3 })
                ]
                []
            ]



{-
       [ name "rating"
       , class "rating"
       ]
       -- workaround for value=""; see https://github.com/elm-lang/html/issues/91
       [ option [ selected (rating == 0), Html.Attributes.attribute "value" "" ] [ text "0" ]
       , option [ selected (rating == 1), value "1" ] [ text "1" ]
       , option [ selected (rating == 2), value "2" ] [ text "2" ]
       , option [ selected (rating == 3), value "3" ] [ text "3" ]
       ]
   ]
-}


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


ratingWidget : List UserRating -> Html Msg
ratingWidget ratings =
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


extractOneUserFromRatings : List UserRating -> CurrentUserName -> List UserRating
extractOneUserFromRatings ratings currentUser =
    case currentUser of
        Nothing ->
            []

        Just simpleUserName ->
            List.filter (\p -> (==) simpleUserName p.userName) ratings


extractOtherUsersFromRatings : List UserRating -> CurrentUserName -> List UserRating
extractOtherUsersFromRatings ratings currentUser =
    case currentUser of
        Nothing ->
            ratings

        Just simpleUserName ->
            List.filter (\p -> (/=) simpleUserName p.userName) ratings


pokemonTile : List UserRatings -> CurrentUserName -> Pokemon -> Html Msg
pokemonTile ratings currentUser pokemon =
    let
        lighthouseData =
            { name = "pokemon", caption = pokemon.name }

        allUserRatings =
            extractOnePokemonFromRatings ratings pokemon

        ownRatings =
            extractOneUserFromRatings allUserRatings currentUser

        otherRatings =
            extractOneUserFromRatings allUserRatings currentUser
    in
        div [ class "poketile" ]
            [ p []
                [ text <| toString pokemon.number
                , linkTo pokemon.url <| text pokemon.name
                ]
            , div [ class "pokemon-image-square" ]
                [ linkToLighthouse pokemon.image lighthouseData <| pokemonImg pokemon.image
                ]
            , ratingWidget otherRatings
            , voteWidget ownRatings pokemon.number
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
