module Model exposing (..)


type alias LighthouseData =
    { name : String
    , title : String
    }


type alias ApplicationState =
    { user : String
    , loggedIn : Bool
    , generation : Int
    , letter : Char
    }


type alias Pokedex =
    { pokemon : List Pokemon
    }


type alias Pokemon =
    { generation : Int
    , number : Int
    , name : String
    , image : String
    , url : String
    , votes : List UserVote
    }


type alias UserVote =
    { user : String
    , rating : Int
    }
