module Models exposing (..)

import Models.Types exposing (..)
import Models.Pokedex exposing (Pokedex)
import Models.Ratings exposing (TeamRatings)
import RemoteData exposing (WebData, RemoteData(..))
import Msgs exposing (Msg)
import Control exposing (State)
import Authentication


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


type alias CurrentUser =
    Maybe String


type alias ApplicationState =
    { authModel : Authentication.Model
    , user : CurrentUser
    , statusMessage : String
    , statusLevel : StatusLevel
    , debounceState : Control.State Msg
    , viewMode : ViewMode
    , generation : Int
    , letter : Char
    , query : String
    , pokedex : WebData Pokedex
    , ratings : WebData TeamRatings
    }
