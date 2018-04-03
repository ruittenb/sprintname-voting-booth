module Commands.Ratings exposing (..)

-- exposing (saveRatings)

import RemoteData exposing (WebData, sendRequest)
import Json.Encode as Encode exposing (Value)
import Json.Decode as Decode exposing (Decoder, decodeValue)
import Json.Decode.Pipeline exposing (decode, required, optional)
import Models.Ratings exposing (RemoteUserRatings, RemoteTeamRatings, UserRatings, TeamRatings)


--import Msgs exposing (Msg)
--import Constants exposing (..)
{-
   saveRatings : UserRatings -> Cmd Msg
   saveRatings userRatings =
       saveUserRatingsRequest userRatings
           |> RemoteData.sendRequest
           |> Cmd.map Msgs.OnSaveRatings


   saveUserRatingsRequest : UserRatings -> Http.Request UserRatings
   saveUserRatingsRequest userRatings =
       Http.request
           { body = userRatingsEncoder userRatings |> Http.jsonBody
           , expect = Http.expectJson decodeUserRatings
           , headers = []
           , method = "PATCH"
           , timeout = Nothing
           , url = saveUserRatingsUrl userRatings.id
           , withCredentials = False
           }

-}


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


userRatingsEncoder : UserRatings -> Value
userRatingsEncoder userRatings =
    let
        attributes =
            [ ( "id", Encode.int userRatings.id )
            , ( "userName", Encode.string userRatings.userName )
            , ( "email", Encode.string userRatings.email )
            , ( "active", Encode.bool userRatings.active )
            , ( "color", Encode.string userRatings.color )
            , ( "ratings", Encode.string userRatings.ratings )
            ]
    in
        Encode.object attributes
