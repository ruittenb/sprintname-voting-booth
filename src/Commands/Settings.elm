module Commands.Settings exposing (decodeSettings)

import RemoteData exposing (fromResult)
import Json.Encode as Encode exposing (Value)
import Json.Decode as Decode exposing (Decoder, decodeValue, bool)
import Json.Decode.Pipeline exposing (decode, required, optional, resolve)
import Models.Settings exposing (..)


decodeSettings : Value -> RemoteSettings
decodeSettings val =
    decodeValue settingsDecoder val
        |> RemoteData.fromResult


settingsDecoder : Decoder Settings
settingsDecoder =
    let
        toDecoder maintenanceMode =
            Decode.succeed (Settings maintenanceMode)
    in
        decode toDecoder
            |> required "maintenanceMode" bool
            |> resolve
