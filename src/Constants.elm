module Constants exposing (..)

import Char


allGenerations : List Int
allGenerations =
    List.range 1 7


allLetters : List Char
allLetters =
    List.map Char.fromCode <|
        List.range (Char.toCode 'A') (Char.toCode 'Z')
