module Update.Settings exposing (updateMaintenanceMode)

import Commands.Settings exposing (saveMaintenanceMode)
import Models exposing (..)
import Msgs exposing (Msg(..))
import RemoteData exposing (RemoteData(..))


updateMaintenanceMode : ApplicationState -> ( ApplicationState, Cmd Msg )
updateMaintenanceMode oldState =
    let
        newSettings =
            oldState.settings
                |> RemoteData.map
                    (\s -> { s | maintenanceMode = not s.maintenanceMode })

        newState =
            { oldState | settings = newSettings }

        newCmd =
            newSettings
                |> RemoteData.map saveMaintenanceMode
                |> RemoteData.withDefault Cmd.none
    in
    ( newState, newCmd )
