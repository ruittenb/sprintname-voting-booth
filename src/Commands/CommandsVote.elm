module CommandsVote exposing (..)

import RemoteData
import Json.Encode as Encode
import Json.Decode as Decode
import Json.Decode.Pipeline exposing (decode, required)
import Msgs exposing (Msg)
import Models exposing (..)


loadRatings : List UserRatings
loadRatings =
    []
