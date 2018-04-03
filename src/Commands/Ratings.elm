module Commands.Ratings exposing (saveRatings, decodeTeamRatings, decodeUserRatings)

import RemoteData exposing (WebData, sendRequest)
import Json.Encode as Encode exposing (Value)
import Json.Decode as Decode exposing (Decoder, decodeValue)
import Json.Decode.Pipeline exposing (decode, required, optional)
import Models.Ratings exposing (RemoteUserRatings, RemoteTeamRatings, UserRatings, TeamRatings)
import Ports exposing (saveUserRatings)


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
        |> required "color" Decode.string
        |> required "ratings" Decode.string
