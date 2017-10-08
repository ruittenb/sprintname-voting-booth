module Constants exposing (..)

import Char


pokedexApiUrl : String
pokedexApiUrl =
    "http://localhost:4202/pokedex"


ratingsApiUrl : String
ratingsApiUrl =
    "http://localhost:4202/users"


saveUserRatingsUrl : Int -> String
saveUserRatingsUrl userId =
    ratingsApiUrl ++ "/" ++ toString userId


maxStars : Int
maxStars =
    3


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
