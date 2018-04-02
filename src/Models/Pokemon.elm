module Models.Pokemon exposing (..)

import RemoteData exposing (RemoteData)


type alias PreloadCandidate =
    { generation : Int
    , imageUrl : String
    }


type alias PokemonVariant =
    { image : String
    , vname : String
    }


type alias Pokemon =
    { id : Int
    , number : Int
    , generation : Int
    , letter : Char
    , name : String
    , url : String
    , currentVariant : Int
    , variants : List PokemonVariant
    }


type alias Pokedex =
    RemoteData String (List Pokemon)
