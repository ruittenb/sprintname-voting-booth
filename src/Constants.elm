module Constants exposing (..)

import Char
import Array exposing (Array)


ratingsApiUrl : String
ratingsApiUrl =
    "http://localhost:4202/users"


pokedexApiUrl : String
pokedexApiUrl =
    "http://localhost:4202/pokedex"


maxStars : Int
maxStars =
    3


triangularNumber : Int -> Int
triangularNumber n =
    List.sum <| List.range 1 n


totalVotes : Int
totalVotes =
    triangularNumber maxStars


totalPokemon : Int
totalPokemon =
    -- zero included
    803


allGenerations : List Int
allGenerations =
    [ 1, 2, 3, 4, 5, 6, 7, 0 ]


allLetters : List Char
allLetters =
    List.map Char.fromCode <|
        List.range (Char.toCode 'A') (Char.toCode 'Z')
