module Models exposing (..)

import Array exposing (Array)
import RemoteData exposing (WebData, succeed)


type StatusLevel
    = Error
    | Notice
    | None


type alias LighthouseData =
    { name : String
    , caption : String
    }


type alias UserVote =
    { pokemonNumber : Int
    , vote : Int
    }


type alias CurrentUser =
    Maybe String


type alias UserRating =
    { id : Int
    , userName : String
    , color : String
    , rating : Int
    }


type alias UserRatings =
    { id : Int
    , userName : String
    , color : String
    , ratings : String
    }


type alias TeamRating =
    List UserRating


type alias TeamRatings =
    List UserRatings


type alias ApplicationState =
    { user : CurrentUser
    , statusMessage : String
    , statusLevel : StatusLevel
    , generation : Int
    , letter : Char
    , cachedGenerations : List Int
    , pokedex : WebData Pokedex
    , ratings : WebData TeamRatings
    }


type alias Pokemon =
    { id : Int
    , number : Int
    , generation : Int
    , letter : Char
    , name : String
    , image : String
    , url : String
    }


type alias Pokedex =
    List Pokemon


missingNo : Pokemon
missingNo =
    { id = 0
    , number = 0
    , generation = 0
    , letter = 'M'
    , name = "MissingNo."
    , image = "https://wiki.p-insurgence.com/images/0/09/722.png"
    , url = "https://bulbapedia.bulbagarden.net/wiki/MissingNo."
    }


initialState : ApplicationState
initialState =
    { user = Nothing
    , statusMessage = ""
    , statusLevel = None
    , generation = 3
    , letter = 'B'
    , cachedGenerations = [ 0 ]
    , pokedex = RemoteData.NotAsked
    , ratings = RemoteData.NotAsked
    }
