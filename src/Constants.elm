module Constants exposing (..)

import Char


maintenanceApology : String
maintenanceApology =
    "The application is in maintenance mode. We apologize for the inconvenience."

pokemonCopyright : String
pokemonCopyright =
    "Pokémon © 1995–2022 Nintendo/ Creatures Inc./ Game Freak Inc. Pokémon and Pokémon character names are trademarks of Nintendo."

rdawCopyright : String
rdawCopyright =
    "The Fakemon presented here are © ReallyDarkandWindie"

debounceDelay : Float
debounceDelay =
    0.5


maxStars : Int
maxStars =
    3


pokeGenerations : List String
pokeGenerations =
    [ "I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "O" ]


rdawGenerations : List String
rdawGenerations =
    [ "i", "ii", "iii", "iv", "v", "vi", "vii", "viii", "ix", "x", "xi", "xii", "xiii", "xiv", "xv", "xvi", "xvii", "xviii", "xix", "xx" ]

genLetterUrlSeparator : String
genLetterUrlSeparator =
    "."

imageDir : String
imageDir =
    "pokeart/"


thumbnailDir : String
thumbnailDir =
    imageDir ++ "thumbs/"


noBreakingSpace : String
noBreakingSpace =
    " "


dateTemplate : String
dateTemplate =
    "EEEE, MMMM d, y"


allGenerations : List String
allGenerations =
    pokeGenerations ++ rdawGenerations


allLetters : List Char
allLetters =
    List.range (Char.toCode 'A') (Char.toCode 'Z')
        |> List.map Char.fromCode
