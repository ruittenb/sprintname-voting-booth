module Helpers exposing (getUserNameForAuthModel, filterPokedex, searchPokedex, romanNumeral)

import Array exposing (Array)
import Regex exposing (regex, caseInsensitive)
import RemoteData exposing (WebData, RemoteData(..))
import Authentication exposing (tryGetUserProfile)
import Models exposing (..)


romanNumerals : Array String
romanNumerals =
    Array.fromList [ "O", "I", "II", "III", "IV", "V", "VI", "VII" ]


romanNumeral : Int -> String
romanNumeral i =
    let
        roman =
            Array.get i romanNumerals
    in
        case roman of
            Just actualRoman ->
                actualRoman

            Nothing ->
                "?"


getUserNameForAuthModel : WebData TeamRatings -> Authentication.Model -> Maybe String
getUserNameForAuthModel ratings authModel =
    let
        userEmail =
            tryGetUserProfile authModel
                |> Maybe.map .email
    in
        case ratings of
            Success teamRatings ->
                teamRatings
                    |> List.filter
                        (\r ->
                            userEmail == Just r.email
                        )
                    |> List.map .userName
                    |> List.head

            _ ->
                Nothing


filterPokedex : WebData Pokedex -> Int -> Char -> List Pokemon
filterPokedex pokedex generation letter =
    let
        selection =
            case pokedex of
                Success pokeList ->
                    pokeList
                        |> List.filter (.letter >> (==) letter)
                        |> List.filter (.generation >> (==) generation)

                _ ->
                    []
    in
        List.sortBy .name selection


searchPokedex : WebData Pokedex -> String -> List Pokemon
searchPokedex pokedex query =
    case pokedex of
        Success pokedex ->
            let
                justNumber =
                    regex "^[0-9]+$"

                pattern =
                    caseInsensitive (regex query)

                pokeList =
                    if Regex.contains justNumber query then
                        -- query by number
                        List.filter (.number >> toString >> (==) query) pokedex
                    else
                        -- query by regex
                        List.filter (.name >> Regex.contains pattern) pokedex
            in
                pokeList

        _ ->
            []
