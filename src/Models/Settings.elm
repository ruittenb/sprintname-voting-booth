module Models.Settings exposing (..)

import RemoteData exposing (RemoteData)


type alias Settings =
    { maintenanceMode : Bool
    }


type alias RemoteSettings =
    RemoteData String Settings
