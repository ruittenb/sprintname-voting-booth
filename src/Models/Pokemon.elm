module Models.Pokemon exposing (..)

import RemoteData exposing (RemoteData)


type alias PreloadCandidate =
    { generation : String
    , letter : Char
    , imageUrl : String
    }


type alias PortCompatiblePreloadCandidate =
    { generation : String
    , letter : String
    , imageUrl : String
    }


type alias PokemonVariant =
    { image : String
    , vname : String
    , description : Maybe String
    }


type alias PokeRanking =
    { pokemonId : Int
    , name : String
    , totalVotes : Int
    }


type alias PokeRankings =
    List PokeRanking


type alias PokeWinner =
    { pokemonId : Int
    , name : String
    }


type alias Pokemon =
    { id : Int
    , number : Int
    , generation : String
    , description : String
    , letter : Char
    , name : String
    , url : String
    , currentVariant : Int
    , variants : List PokemonVariant
    }


type alias Pokedex =
    List Pokemon


type alias RemotePokedex =
    RemoteData String Pokedex
