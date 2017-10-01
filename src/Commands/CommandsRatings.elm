module CommandsRatings exposing (..)

import RemoteData
import Json.Encode as Encode
import Json.Decode as Decode
import Json.Decode.Pipeline exposing (decode, required)
import Constants exposing (..)
import Models exposing (..)
import Msgs exposing (Msg)


loadRatings : Result (List UserRatings)
loadRatings =
    []


saveRatings : List UserRatings -> Cmd Msg
saveRatings userRatings =
    saveRatingsRequest userRatings
        |> Http.send Msgs.OnSaveRatings
