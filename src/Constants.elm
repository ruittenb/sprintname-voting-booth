module Constants exposing (..)

import Char


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
