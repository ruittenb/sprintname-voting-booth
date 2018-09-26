module Helpers exposing (getUserNameForAuthModel, filterPokedex, searchPokedex, romanNumeral)

import Array exposing (Array)
import Regex exposing (regex, caseInsensitive)
import RemoteData exposing (WebData, RemoteData(..))
import Models.Authentication exposing (AuthenticationModel)
import Models.Pokemon exposing (..)
import Models.Ratings exposing (..)
import Helpers.Authentication exposing (tryGetUserProfile)


romanNumerals : Array String
romanNumerals =
    Array.fromList [ "O", "I", "II", "III", "IV", "V", "VI", "VII", "VIII" ]


romanNumeral : Int -> String
romanNumeral i =
    Array.get i romanNumerals
        |> Maybe.withDefault "?"


isNumeric : String -> Bool
isNumeric str =
    Regex.contains (regex "^[0-9]+$") str


getUserNameForAuthModel : RemoteTeamRatings -> AuthenticationModel -> Maybe String
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
                            userEmail == Just r.email && r.active == True
                        )
                    |> List.map .userName
                    |> List.head

            _ ->
                Nothing


filterPokedex : RemotePokedex -> Int -> Char -> List Pokemon
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


searchPokedex : RemotePokedex -> String -> List Pokemon
searchPokedex pokedex query =
    case pokedex of
        Success pokedex ->
            let
                queryPattern =
                    caseInsensitive (regex query)

                pokeList =
                    if isNumeric query then
                        List.filter (.number >> toString >> (==) query) pokedex
                    else
                        List.filter (.name >> Regex.contains queryPattern) pokedex
            in
                pokeList

        _ ->
            []
