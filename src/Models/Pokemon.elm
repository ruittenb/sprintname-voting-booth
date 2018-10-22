module Models.Pokemon exposing (..)

import RemoteData exposing (RemoteData)


type alias PreloadCandidate =
    { generation : Int
    , letter : Char
    , imageUrl : String
    }


type alias PortCompatiblePreloadCandidate =
    { generation : Int
    , letter : String
    , imageUrl : String
    }


type alias PokemonVariant =
    { image : String
    , vname : String
    }


type alias PokeRanking =
    { number : Int
    , name : String
    , totalVotes : Int
    }


type alias PokeRankings =
    List PokeRanking


type alias Pokemon =
    { id : Int
    , number : Int
    , generation : Int
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
