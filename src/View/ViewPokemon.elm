module ViewPokemon exposing (pokemonCanvas)

import List
import Maybe
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import RemoteData exposing (WebData, RemoteData(..))
import Constants exposing (maxStars)
import Helpers exposing (filterPokedex)
import Models exposing (..)
import Msgs exposing (Msg)


loadingBusyIcon : Html Msg
loadingBusyIcon =
    div [ class "loading-busy" ] []


loadingErrorIcon : Html Msg
loadingErrorIcon =
    div [ class "loading-error" ] []


unknownUserIcon : Html Msg
unknownUserIcon =
    div [ class "unknown-user" ] []


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


voteWidgetStar : Int -> String -> Int -> Int -> Html Msg
voteWidgetStar pokemonNumber currentUserName rating stars =
    span
        [ classList
            [ ( "star", True )
            , ( "selected", rating >= stars )
            ]
        , onClick (Msgs.VoteForPokemon { pokemonNumber = pokemonNumber, vote = stars })
        , title <| currentUserName ++ ": " ++ (toString stars)
        ]
        []


voteWidget : TeamRating -> Int -> String -> Html Msg
voteWidget ownRatings pokemonNumber currentUserName =
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
        span [ class "voting-node" ] <|
            List.map
                (voteWidgetStar pokemonNumber currentUserName rating)
                (List.range 1 maxStars)


ratingNode : UserRating -> Html Msg
ratingNode rating =
    let
        star =
            span [ class "star" ] []

        userTitle =
            rating.userName ++ ": " ++ toString rating.rating
    in
        span
            [ title userTitle
            , style [ ( "color", rating.color ) ]
            ]
        <|
            List.repeat rating.rating star


ratingWidget : TeamRating -> Html Msg
ratingWidget ratings =
    div
        [ class "rating-nodes"
        ]
    <|
        List.map ratingNode ratings


extractOnePokemonFromRatings : WebData TeamRatings -> Pokemon -> TeamRating
extractOnePokemonFromRatings ratings pokemon =
    case ratings of
        Success actualRatings ->
            List.map
                (\r ->
                    { id = r.id
                    , userName = r.userName
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


extractOneUserFromRatings : TeamRatings -> CurrentUser -> ( TeamRating, TeamRating )
extractOneUserFromRatings ratings currentUser =
    case currentUser of
        Nothing ->
            ( [], ratings )

        Just simpleUserName ->
            List.partition (.userName >> (==) simpleUserName) ratings


pokemonTile : WebData TeamRatings -> CurrentUser -> Pokemon -> Html Msg
pokemonTile ratings currentUser pokemon =
    let
        lighthouseData =
            { name = "pokemon", caption = pokemon.name }

        allUserRatings =
            extractOnePokemonFromRatings ratings pokemon

        ( ownRatings, otherRatings ) =
            extractOneUserFromRatings allUserRatings currentUser

        actualVoteWidget =
            case currentUser of
                Nothing ->
                    unknownUserIcon

                Just actualUserName ->
                    voteWidget ownRatings pokemon.number actualUserName
    in
        div [ class "poketile" ] <|
            [ p []
                [ text <| toString pokemon.number
                , linkTo pokemon.url <| text pokemon.name
                ]
            , div [ class "pokemon-image-strip-box" ]
                [ div [] []
                , (linkToLighthouse pokemon.image lighthouseData <| pokemonImg pokemon.image)
                , div [] []
                ]
            ]
                ++ case ratings of
                    Success _ ->
                        [ ratingWidget otherRatings
                        , actualVoteWidget
                        ]

                    Failure _ ->
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
