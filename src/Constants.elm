module Constants exposing (..)

import Char


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
    8


imageDir : String
imageDir =
    "pokeart/"


noBreakingSpace : String
noBreakingSpace =
    " "


allGenerations : List Int
allGenerations =
    List.range 1 maxGeneration
        ++ [ 0 ]


allLetters : List Char
allLetters =
    List.range (Char.toCode 'A') (Char.toCode 'Z')
        |> List.map Char.fromCode
