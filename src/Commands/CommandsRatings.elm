module CommandsRatings exposing (..)

import RemoteData
import Http
import Json.Encode as Encode
import Json.Decode as Decode exposing (Decoder, decodeValue)
import Json.Decode.Pipeline exposing (decode, required, optional)
import Constants exposing (..)
import Models exposing (..)
import Msgs exposing (Msg)


exampleTeamRatings : Encode.Value
exampleTeamRatings =
    Encode.object
        [ ( "users"
          , Encode.list
                [ Encode.object
                    [ ( "userName", Encode.string "Brian" )
                    , ( "color", Encode.string "blue" )
                    , ( "ratings", Encode.string "1020010012" )
                    ]
                , Encode.object
                    [ ( "userName", Encode.string "René" )
                    , ( "color", Encode.string "green" )
                    , ( "ratings", Encode.string "0101020010" )
                    ]
                ]
          )
        ]


loadRatings : Cmd Msg
loadRatings =
    decodeValue decodeTeamRatings exampleTeamRatings



--        |> Cmd.map Msgs.OnLoadRatings
--        |> Msgs.OnLoadRatings
{-
   Http.get ratingsApiUrl decodeTeamRatings
       |> RemoteData.sendRequest
       |> Cmd.map Msgs.OnLoadRatings
-}
{-
   saveRatings : TeamRatings -> Cmd Msg
   saveRatings teamRatings =
       saveRatingsRequest teamRatings
           |> Http.send Msgs.OnSaveRatings
-}


decodeTeamRatings : Decoder TeamRatingsJson
decodeTeamRatings =
    decode TeamRatingsJson
        |> required "users" (Decode.list decodeUserRatings)


decodeUserRatings : Decoder UserRatings
decodeUserRatings =
    decode UserRatings
        |> required "userName" Decode.string
        |> required "color" Decode.string
        |> required "ratings" Decode.string
