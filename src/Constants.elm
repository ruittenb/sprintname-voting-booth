module Constants exposing (..)

import Char


initialGeneration : Int
initialGeneration =
    5


initialLetter : Char
initialLetter =
    'M'


maintenanceApology : String
maintenanceApology =
    "The application is in maintenance mode. We apologize for the inconvenience."


debounceDelay : Float
debounceDelay =
    0.5


maxStars : Int
maxStars =
    3


maxGeneration : Int
maxGeneration =
    7


totalPokemon : Int
totalPokemon =
    -- zero included
    809


imageDir : String
imageDir =
    "pokeart/"


allGenerations : List Int
allGenerations =
    List.range 1 maxGeneration
        ++ [ 0 ]


allLetters : List Char
allLetters =
    List.map Char.fromCode <|
        List.range (Char.toCode 'A') (Char.toCode 'Z')
