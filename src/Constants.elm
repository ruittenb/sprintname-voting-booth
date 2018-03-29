module Constants exposing (..)

import Char


dbHostname : String
dbHostname =
    --"192.168.1.190"
    --"sprintname-voting-booth.ruittenbook.local"
    --"votingbooth.ddns.net"
    "localhost"


pokedexApiUrl : String
pokedexApiUrl =
    "http://" ++ dbHostname ++ ":4202/pokedex"


ratingsApiUrl : String
ratingsApiUrl =
    "http://" ++ dbHostname ++ ":4202/users"


saveUserRatingsUrl : Int -> String
saveUserRatingsUrl userId =
    ratingsApiUrl ++ "/" ++ toString userId


debounceDelay : Float
debounceDelay =
    0.5


initialGeneration : Int
initialGeneration =
    3


initialLetter : Char
initialLetter =
    'P'


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
