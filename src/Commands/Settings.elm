module Commands.Settings exposing (decodeSettings, saveMaintenanceMode)

import Json.Decode as Decode exposing (Decoder, bool, decodeValue)
import Json.Decode.Pipeline exposing (decode, optional, required, resolve)
import Json.Encode as Encode exposing (Value)
import Models.Settings exposing (..)
import Ports exposing (saveSettings)
import RemoteData exposing (fromResult)


saveMaintenanceMode : Settings -> Cmd msg
saveMaintenanceMode settings =
    saveSettings settings


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
