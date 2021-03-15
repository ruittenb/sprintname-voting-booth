module Commands.Authentication exposing (decodeUser)

--import RemoteData exposing (WebData, sendRequest)

import Json.Decode as Decode exposing (Decoder, bool, decodeValue, int, string)
import Json.Decode.Pipeline exposing (decode, optional, required)
import Json.Encode as Encode exposing (Value)
import Models.Auth exposing (LoggedInUser, RemoteLoggedInUser, UserProfile)


decodeUser : Value -> RemoteLoggedInUser
decodeUser val =
    decodeValue userDecoder val


userDecoder : Decoder LoggedInUser
userDecoder =
    decode LoggedInUser
        |> required "idToken" string
        |> required "accessToken" string
        |> required "profile" userProfileDecoder


userProfileDecoder : Decoder UserProfile
userProfileDecoder =
    decode UserProfile
        |> required "sub" string
        |> required "email" string
        |> required "email_verified" bool
        |> required "given_name" string
        |> required "family_name" string
        |> required "nickname" string
        |> required "name" string
        |> required "picture" string
        |> required "locale" string
        |> required "updated_at" string
