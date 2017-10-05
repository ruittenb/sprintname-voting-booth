module Constants exposing (..)

import Char
import Array exposing (Array)


ratingsApiUrl : String
ratingsApiUrl =
    "http://localhost:4202/users"


pokemonApiUrl : String
pokemonApiUrl =
    "https://pokeapi.co/api/v2/pokemon/"


pokemonImageBaseUrl : String
pokemonImageBaseUrl =
    "https://assets.pokemon.com/assets/cms2/img/pokedex/full/"


wikiUrl : String -> String
wikiUrl name =
    "https://bulbapedia.bulbagarden.net/wiki/" ++ name ++ "_(Pok%C3%A9mon)"


maxStars : Int
maxStars =
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


generations : Array ( Int, Int )
generations =
    Array.fromList
        [ ( 0, 0 )
        , ( 1, 151 )
        , ( 152, 251 )
        , ( 252, 386 )
        , ( 387, 493 )
        , ( 494, 649 )
        , ( 650, 721 )
        , ( 722, 802 )
        ]


allLetters : List Char
allLetters =
    List.map Char.fromCode <|
        List.range (Char.toCode 'A') (Char.toCode 'Z')
