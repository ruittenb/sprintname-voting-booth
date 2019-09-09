module Update.Settings exposing (updateMaintenanceMode)

import RemoteData exposing (RemoteData(..))
import Models exposing (..)
import Msgs exposing (Msg(..))
import Commands.Settings exposing (saveMaintenanceMode)


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
