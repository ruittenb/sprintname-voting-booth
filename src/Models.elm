module Models exposing (..)

import Array exposing (Array)
import RemoteData exposing (WebData, succeed)
import Constants exposing (totalPokemon)


type StatusLevel
    = Error
    | Notice
    | None


type alias LighthouseData =
    { name : String
    , caption : String
    }


type alias GenerationTuple =
    ( Int, Int )


type alias UserVote =
    { pokemonNumber : Int
    , vote : Int
    }


type alias CurrentUser =
    Maybe String


type alias UserRating =
    { userName : String
    , color : String
    , rating : Int
    }


type alias UserRatings =
    { userName : String
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
    , pokedex : Pokedex
    , ratings : WebData TeamRatings
    }


type alias Pokemon =
    { number : Int
    , name : String
    , image : String
    , url : String
    }


type alias Pokedex =
    Array (WebData Pokemon)


missingNoImgUrl : String
missingNoImgUrl =
    "https://wiki.p-insurgence.com/images/0/09/722.png"


missingNo : Pokemon
missingNo =
    { number = 0
    , name = "MissingNo."
    , image = missingNoImgUrl
    , url = "https://bulbapedia.bulbagarden.net/wiki/MissingNo."
    }


initialPokedex : Pokedex
initialPokedex =
    Array.fromList <|
        RemoteData.succeed missingNo
            :: List.repeat
                (totalPokemon - 1)
                RemoteData.NotAsked


initialState : ApplicationState
initialState =
    { user = Nothing
    , statusMessage = ""
    , statusLevel = None
    , generation = 3
    , letter = 'B'
    , cachedGenerations = [ 0 ]
    , pokedex = initialPokedex
    , ratings = RemoteData.NotAsked
    }
