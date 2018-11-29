module Models.Ratings exposing (..)

import RemoteData exposing (RemoteData)


type alias UserVote =
    { pokemonNumber : Int
    , vote : Int
    }


type alias UserRating =
    { id : Int
    , userName : String
    , email : String
    , active : Bool
    , admin : Bool
    , color : String
    , rating : Int
    }


type alias TeamRating =
    List UserRating


type alias UserRatings =
    { id : Int
    , userName : String
    , email : String
    , active : Bool
    , admin : Bool
    , color : String
    , ratings : String
    }


type alias TeamRatings =
    List UserRatings


type alias RemoteUserRatings =
    RemoteData String UserRatings


type alias RemoteTeamRatings =
    RemoteData String TeamRatings


type CompletionLevel
    = Absent
    | Incomplete
    | Complete


type alias TeamGenLetterVote =
    { userId : Int
    , userName : String
    , totalVotes : Int
    , completionLevel : CompletionLevel
    }


type alias TeamGenLetterVotes =
    List TeamGenLetterVote
