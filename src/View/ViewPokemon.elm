module ViewPokemon exposing (..)

import List exposing (..)
import Maybe exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Numeral exposing (format)
import Constants exposing (pokemonImageBaseUrl)
import RemoteData exposing (WebData)


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


loadingBusyIcon : Html Msg
loadingBusyIcon =
    div [ class "loading-busy" ]
        []


loadingErrorIcon : Html Msg
loadingErrorIcon =
    div [ class "loading-error" ]
        []


linkTo : String -> Html Msg -> Html Msg
linkTo url content =
    a
        [ href url
        , target "_blank"
        ]
        [ content ]


linkToLighthouse : String -> LighthouseData -> Html Msg -> Html Msg
linkToLighthouse imageUrl lighthouseData content =
    a
        [ href imageUrl
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


getPokemonImgUrl : Int -> String
getPokemonImgUrl pokemonNumber =
    case pokemonNumber of
        0 ->
            missingNoImgUrl

        _ ->
            pokemonImageBaseUrl ++ format "000" (toFloat pokemonNumber) ++ ".png"


voteWidget : TeamRating -> Int -> String -> Html Msg
voteWidget ownRatings pokemonNumber currentUser =
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
                , title <| currentUser ++ ": 1"
                ]
                []
            , span
                [ classList
                    [ ( "star", True )
                    , ( "selected", rating > 1 )
                    ]
                , onClick (Msgs.VoteForPokemon { userVote | vote = 2 })
                , title <| currentUser ++ ": 2"
                ]
                []
            , span
                [ classList
                    [ ( "star", True )
                    , ( "selected", rating > 2 )
                    ]
                , onClick (Msgs.VoteForPokemon { userVote | vote = 3 })
                , title <| currentUser ++ ": 3"
                ]
                []
            ]


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


ratingWidget : TeamRating -> Html Msg
ratingWidget ratings =
    div [ class "rating-nodes" ] <| List.map ratingNode ratings


extractOnePokemonFromRatings : WebData TeamRatings -> Pokemon -> TeamRating
extractOnePokemonFromRatings ratings pokemon =
    case ratings of
        RemoteData.Success actualRatings ->
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
                actualRatings

        _ ->
            []


extractOneUserFromRatings : TeamRating -> CurrentUser -> TeamRating
extractOneUserFromRatings ratings currentUser =
    case currentUser of
        Nothing ->
            []

        Just simpleUserName ->
            List.filter (\p -> (==) simpleUserName p.userName) ratings


extractOtherUsersFromRatings : TeamRating -> CurrentUser -> TeamRating
extractOtherUsersFromRatings ratings currentUser =
    case currentUser of
        Nothing ->
            ratings

        Just simpleUserName ->
            List.filter (\p -> (/=) simpleUserName p.userName) ratings


pokemonTile : WebData TeamRatings -> CurrentUser -> Pokemon -> Html Msg
pokemonTile ratings currentUser pokemon =
    let
        lighthouseData =
            { name = "pokemon", caption = pokemon.name }

        allUserRatings =
            extractOnePokemonFromRatings ratings pokemon

        ownRatings =
            extractOneUserFromRatings allUserRatings currentUser

        otherRatings =
            extractOtherUsersFromRatings allUserRatings currentUser

        actualVoteWidget =
            case currentUser of
                Nothing ->
                    text ""

                Just actualUserName ->
                    voteWidget ownRatings pokemon.number actualUserName

        pokemonImgUrl =
            getPokemonImgUrl pokemon.number
    in
        div [ class "poketile" ] <|
            [ p []
                [ text <| toString pokemon.number
                , linkTo pokemon.url <| text pokemon.name
                ]
            , div [ class "pokemon-image-square" ]
                [ linkToLighthouse pokemonImgUrl lighthouseData <| pokemonImg pokemonImgUrl
                ]
            ]
                ++ case ratings of
                    RemoteData.Success _ ->
                        [ ratingWidget otherRatings
                        , actualVoteWidget
                        ]

                    RemoteData.Failure _ ->
                        [ loadingErrorIcon ]

                    _ ->
                        [ loadingBusyIcon ]


pokemonTiles : List Pokemon -> WebData TeamRatings -> CurrentUser -> List (Html Msg)
pokemonTiles pokelist ratings currentUser =
    List.map (pokemonTile ratings currentUser) pokelist


pokemonCanvas : ApplicationState -> Html Msg
pokemonCanvas state =
    let
        pokeList =
            filterPokedex state.pokedex state.generation state.letter
    in
        div [ class "pokecanvas" ] <| pokemonTiles pokeList state.ratings state.user
