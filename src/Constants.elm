module Constants exposing (..)

import Char


ratingsApiUrl : String
ratingsApiUrl =
    "http://localhost:4202/users"


pokemonApiUrl : String
pokemonApiUrl =
    "http://pokeapi.co/api/v2/pokemon/"


pokemonImageBaseUrl : String
pokemonImageBaseUrl =
    "https://assets.pokemon.com/assets/cms2/img/pokedex/full/"


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
