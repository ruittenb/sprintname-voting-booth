module Constants exposing (..)

import Char


debounceDelay : Float
debounceDelay =
    0.5


initialGeneration : Int
initialGeneration =
    3


initialLetter : Char
initialLetter =
    'S'


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
