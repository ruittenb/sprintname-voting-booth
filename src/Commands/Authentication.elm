module Commands.Authentication exposing (decodeUser)

--import RemoteData exposing (WebData, sendRequest)

import Models.Auth exposing (RemoteLoggedInUser, LoggedInUser, UserProfile)
import Json.Encode as Encode exposing (Value)
import Json.Decode as Decode exposing (Decoder, decodeValue, string, int, bool)
import Json.Decode.Pipeline exposing (decode, required, optional)


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
