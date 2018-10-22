module View.Pokemon exposing (pokemonCanvas)

import List
import Maybe
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import RemoteData exposing (WebData, RemoteData(..))
import Constants exposing (maxStars, imageDir)
import Helpers exposing (filterPokedex, searchPokedex, romanNumeral)
import Models exposing (..)
import Models.Types exposing (..)
import Models.Ratings exposing (..)
import Models.Pokemon exposing (..)
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


countCompleteVotes : TeamRating -> Int
countCompleteVotes teamRating =
    List.map .rating teamRating
        |> List.sum


linkTo : String -> Html Msg -> Html Msg
linkTo url content =
    a
        [ href url
        , target "_blank"
        ]
        [ content ]


linkToLighthouse : String -> String -> String -> Html Msg -> Html Msg
linkToLighthouse imageUrl title caption content =
    a
        [ href imageUrl
        , Html.Attributes.attribute "data-lightbox" "pokemon"
        , Html.Attributes.attribute "data-title" title
        , Html.Attributes.attribute "data-caption" caption
        ]
        [ content ]


pokemonImg : String -> String -> Html Msg
pokemonImg imageUrl altText =
    img
        [ src imageUrl
        , class "pokemon-image"
        , alt altText
        , title altText
        ]
        []


voteWidgetStar : Int -> String -> Int -> Int -> Html Msg
voteWidgetStar pokemonNumber currentUserName rating stars =
    span
        [ classList
            [ ( "star", True )
            , ( "fa", True )
            , ( "fa-star-o", rating < stars )
            , ( "fa-star", rating >= stars )
            , ( "selected", rating >= stars )
            ]
        , onClick (Msgs.PokemonVoteCast { pokemonNumber = pokemonNumber, vote = stars })
        , title <| currentUserName ++ ": " ++ (toString stars)
        ]
        []


voteWidget : TeamRating -> Int -> String -> Html Msg
voteWidget currentUserRating pokemonNumber currentUserName =
    let
        userVote =
            { pokemonNumber = pokemonNumber
            , vote = 0
            }

        rating =
            List.head currentUserRating
                |> Maybe.map .rating
                |> Maybe.withDefault 0
    in
        span [ class "voting-node" ] <|
            List.map
                (voteWidgetStar pokemonNumber currentUserName rating)
                (List.range 1 maxStars)


ratingNode : UserRating -> Html Msg
ratingNode rating =
    let
        star =
            span
                [ classList
                    [ ( "star", True )
                    , ( "fa-star", True )
                    , ( "fa", True )
                    ]
                ]
                []

        userTitle =
            rating.userName ++ ": " ++ toString rating.rating
    in
        span
            [ title userTitle
            , style [ ( "color", rating.color ) ]
            ]
        <|
            List.repeat rating.rating star


ratingWidget : TeamRating -> Html Msg -> Html Msg
ratingWidget otherUsersRating actualVoteWidget =
    div
        [ class "rating-nodes"
        ]
    <|
        (List.map ratingNode otherUsersRating)
            ++ [ actualVoteWidget ]



{- in: a list of user data with ratings array.
   out: a list of user data with rating element (integer) for the specified pokemon.
-}


extractOnePokemonFromRatings : RemoteTeamRatings -> Pokemon -> TeamRating
extractOnePokemonFromRatings ratings pokemon =
    case ratings of
        Success actualRatings ->
            List.map
                (\r ->
                    { id = r.id
                    , userName = r.userName
                    , email = r.email
                    , active = r.active
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


extractOneUserFromRatings : TeamRating -> User -> ( TeamRating, TeamRating )
extractOneUserFromRatings ratings currentUser =
    case currentUser of
        Nothing ->
            ( [], ratings )

        Just simpleUserName ->
            List.partition (.userName >> (==) simpleUserName) ratings


variantLink : String -> String -> PokemonVariant -> Html Msg
variantLink pokemonName description variant =
    let
        title =
            if String.length variant.vname > 0 then
                pokemonName ++ " (" ++ variant.vname ++ ")"
            else
                pokemonName

        url =
            imageDir ++ variant.image
    in
        pokemonImg url variant.vname
            |> linkToLighthouse url title description


variantLinks : String -> String -> List PokemonVariant -> List (Html Msg)
variantLinks pokemonName description variants =
    List.map (variantLink pokemonName description) variants


pokemonTile : ViewMode -> RemoteTeamRatings -> User -> Pokemon -> Html Msg
pokemonTile viewMode ratings currentUser pokemon =
    let
        teamRating =
            extractOnePokemonFromRatings ratings pokemon

        totalVotes =
            countCompleteVotes teamRating

        ( currentUserRating, otherUsersRating ) =
            extractOneUserFromRatings teamRating currentUser

        leftMargin =
            toString (-120 * (pokemon.currentVariant - 1)) ++ "px"

        hash =
            "#" ++ (toString pokemon.generation) ++ (String.fromChar pokemon.letter)

        generationElement : Int -> List (Html Msg)
        generationElement gen =
            case viewMode of
                Browse ->
                    [ text "" ]

                Search ->
                    [ a
                        [ href hash
                        , classList [ ( "button", True ) ]
                        ]
                        [ text (romanNumeral gen)
                        ]
                    , text " " -- no-breaking space
                    ]

        actualVoteWidget =
            case currentUser of
                Nothing ->
                    text ""

                Just actualUserName ->
                    voteWidget currentUserRating pokemon.number actualUserName
    in
        div
            [ class "poketile"
            , "Total: " ++ toString totalVotes |> title
            , toString totalVotes |> attribute "data-votes"
            , pokemon.name |> attribute "data-name"
            ]
        <|
            [ p []
                [ span [] <|
                    (generationElement pokemon.generation)
                        ++ [ toString pokemon.number |> text ]
                , text pokemon.name |> linkTo pokemon.url
                ]
            , div [ class "pokemon-image-strip-box" ]
                [ div
                    [ classList
                        [ ( "left-arrow", List.length pokemon.variants > 1 )
                        ]
                    , onClick (Msgs.VariantChanged pokemon.number Prev)
                    ]
                    []
                , div [ class "pokemon-image-box" ]
                    [ span
                        [ class "pokemon-image-strip"
                        , style [ ( "margin-left", leftMargin ) ]
                        , List.length pokemon.variants
                            |> toString
                            |> Html.Attributes.attribute "data-variants"
                        ]
                      <|
                        variantLinks pokemon.name pokemon.description pokemon.variants
                    ]
                , div
                    [ classList
                        [ ( "right-arrow", List.length pokemon.variants > 1 )
                        ]
                    , onClick (Msgs.VariantChanged pokemon.number Next)
                    ]
                    []
                ]
            ]
                ++ case ratings of
                    Success _ ->
                        [ ratingWidget otherUsersRating actualVoteWidget ]

                    Failure _ ->
                        [ loadingErrorIcon ]

                    _ ->
                        [ loadingBusyIcon ]


pokemonTiles : ViewMode -> List Pokemon -> RemoteTeamRatings -> User -> List (Html Msg)
pokemonTiles viewMode pokelist ratings currentUser =
    List.map (pokemonTile viewMode ratings currentUser) pokelist


pokemonCanvas : ApplicationState -> Html Msg
pokemonCanvas state =
    let
        pokeList =
            case state.viewMode of
                Browse ->
                    filterPokedex state.pokedex state.generation state.letter

                Search ->
                    searchPokedex state.pokedex state.query
    in
        div [ class "pokecanvas" ] <| pokemonTiles state.viewMode pokeList state.ratings state.currentUser
