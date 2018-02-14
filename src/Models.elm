module Models exposing (..)

import RemoteData exposing (WebData, RemoteData(..))
import Authentication


type BrowseDirection
    = Next
    | Prev


type ViewMode
    = Search
    | Browse


type StatusLevel
    = Error
    | Warning
    | Notice
    | Debug
    | None


type alias LighthouseData =
    { name : String
    , caption : String
    }


type alias Subpage =
    { generation : Int
    , letter : Char
    }


type alias PreloadCandidate =
    { generation : Int
    , imageUrl : String
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
    List Pokemon


type alias ApplicationState =
    { authModel : Authentication.Model
    , user : CurrentUser
    , statusMessage : String
    , statusLevel : StatusLevel
    , viewMode : ViewMode
    , generation : Int
    , letter : Char
    , query : String
    , pokedex : WebData Pokedex
    , ratings : WebData TeamRatings
    }
