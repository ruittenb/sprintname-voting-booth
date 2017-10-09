module Constants exposing (..)

import Char


dbHostname : String
dbHostname =
    "sprintname-voting-booth.ruittenbook.local"


pokedexApiUrl : String
pokedexApiUrl =
    "http://" ++ dbHostname ++ ":4202/pokedex"


ratingsApiUrl : String
ratingsApiUrl =
    "http://" ++ dbHostname ++ ":4202/users"


saveUserRatingsUrl : Int -> String
saveUserRatingsUrl userId =
    ratingsApiUrl ++ "/" ++ toString userId


initialGeneration : Int
initialGeneration =
    3


initialLetter : Char
initialLetter =
    'C'


maxStars : Int
maxStars =
    3


maxGeneration : Int
maxGeneration =
    7


totalPokemon : Int
totalPokemon =
    -- zero included
    803


allGenerations : List Int
allGenerations =
    List.range 1 maxGeneration
        ++ [ 0 ]


allLetters : List Char
allLetters =
    List.map Char.fromCode <|
        List.range (Char.toCode 'A') (Char.toCode 'Z')
