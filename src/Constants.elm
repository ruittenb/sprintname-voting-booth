module Constants exposing (..)

import Char


maxStars : Int
maxStars =
    -- TODO not yet implemented. see ViewPokemon.voteWidget
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
