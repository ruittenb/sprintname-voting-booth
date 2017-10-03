module CommandsRatings exposing (..)

import Http exposing (get)
import RemoteData exposing (WebData, sendRequest)
import Json.Encode as Encode
import Json.Decode as Decode exposing (Decoder, decodeValue)
import Json.Decode.Pipeline exposing (decode, required, optional)
import Constants exposing (..)
import Models exposing (..)
import Msgs exposing (Msg)


loadRatings : Cmd Msg
loadRatings =
    Http.get ratingsApiUrl decodeTeamRatings
        |> RemoteData.sendRequest
        |> Cmd.map Msgs.OnLoadRatings



{-
   saveRatings : TeamRatings -> Cmd Msg
   saveRatings teamRatings =
       saveRatingsRequest teamRatings
           |> Http.send Msgs.OnSaveRatings
-}


decodeTeamRatings : Decoder TeamRatings
decodeTeamRatings =
    Decode.list decodeUserRatings


decodeUserRatings : Decoder UserRatings
decodeUserRatings =
    decode UserRatings
        |> required "userName" Decode.string
        |> required "color" Decode.string
        |> required "ratings" Decode.string
