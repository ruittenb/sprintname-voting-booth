module Commands.Ratings exposing (decodeTeamRatings, decodeUserRatings, saveRatings)

import Json.Decode as Decode exposing (Decoder, decodeValue)
import Json.Decode.Pipeline exposing (decode, optional, required)
import Json.Encode as Encode exposing (Value)
import Models.Ratings exposing (RemoteTeamRatings, RemoteUserRatings, TeamRatings, UserRatings)
import Ports exposing (saveUserRatings)
import RemoteData exposing (WebData, sendRequest)


saveRatings : UserRatings -> Cmd msg
saveRatings userRatings =
    saveUserRatings userRatings


decodeTeamRatings : Value -> RemoteTeamRatings
decodeTeamRatings val =
    decodeValue teamRatingsDecoder val
        |> RemoteData.fromResult


decodeUserRatings : Value -> RemoteUserRatings
decodeUserRatings val =
    decodeValue userRatingsDecoder val
        |> RemoteData.fromResult


teamRatingsDecoder : Decoder TeamRatings
teamRatingsDecoder =
    Decode.list userRatingsDecoder


userRatingsDecoder : Decoder UserRatings
userRatingsDecoder =
    decode UserRatings
        |> required "id" Decode.int
        |> required "userName" Decode.string
        |> required "email" Decode.string
        |> required "active" Decode.bool
        |> required "admin" Decode.bool
        |> required "color" Decode.string
        |> required "ratings" Decode.string
