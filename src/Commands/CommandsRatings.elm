module CommandsRatings exposing (loadRatings, saveRatings)

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


saveRatings : UserRatings -> Cmd Msg
saveRatings userRatings =
    saveUserRatingsRequest userRatings
        |> RemoteData.sendRequest
        |> Cmd.map Msgs.OnSaveRatings


saveUserRatingsRequest : UserRatings -> Http.Request UserRatings
saveUserRatingsRequest userRatings =
    Http.request
        { body = encodeUserRatings userRatings |> Http.jsonBody
        , expect = Http.expectJson decodeUserRatings
        , headers = []
        , method = "PATCH"
        , timeout = Nothing
        , url = saveUserRatingsUrl userRatings.id
        , withCredentials = False
        }


decodeTeamRatings : Decoder TeamRatings
decodeTeamRatings =
    Decode.list decodeUserRatings


decodeUserRatings : Decoder UserRatings
decodeUserRatings =
    decode UserRatings
        |> required "id" Decode.int
        |> required "userName" Decode.string
        |> required "color" Decode.string
        |> required "ratings" Decode.string


encodeUserRatings : UserRatings -> Encode.Value
encodeUserRatings userRatings =
    let
        attributes =
            [ ( "id", Encode.int userRatings.id )
            , ( "userName", Encode.string userRatings.userName )
            , ( "color", Encode.string userRatings.color )
            , ( "ratings", Encode.string userRatings.ratings )
            ]
    in
        Encode.object attributes
