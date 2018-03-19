module Models.Ratings exposing (..)


type alias UserVote =
    { pokemonNumber : Int
    , vote : Int
    }


type alias UserRating =
    { id : Int
    , userName : String
    , email : String
    , active : Bool
    , color : String
    , rating : Int
    }


type alias UserRatings =
    { id : Int
    , userName : String
    , email : String
    , active : Bool
    , color : String
    , ratings : String
    }


type alias TeamRating =
    List UserRating


type alias TeamRatings =
    List UserRatings
