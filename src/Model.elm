module Model exposing (..)


type alias LighthouseData =
    { name : String
    , title : String
    }


type alias ApplicationState =
    { user : Maybe String
    , loggedIn : Bool
    , generation : Int
    , letter : Char
    , votes : List UserVote
    }


type alias UserVote =
    { user : String
    , pokemonNr : Int
    , rating : Int
    }


type alias Pokedex =
    { pokemon : List Pokemon
    , cachedGenerations : List Int
    }


type alias Pokemon =
    { generation : Int
    , number : Int
    , name : String
    , image : String
    , url : String
    }
