module Models exposing (..)

import Models.Types exposing (..)
import Models.Pokemon exposing (Pokedex)
import Models.Ratings exposing (TeamRatings)
import Msgs exposing (Msg)
import Authentication
import Control exposing (State)
import RemoteData exposing (WebData, RemoteData(..))


type alias LighthouseData =
    { name : String
    , caption : String
    }


type alias Subpage =
    { generation : Int
    , letter : Char
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
    , pokedex : RemoteData String Pokedex
    , ratings : WebData TeamRatings
    }
