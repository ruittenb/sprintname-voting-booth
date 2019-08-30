module Commands exposing (..)

import Task exposing (perform)
import Time exposing (now, hour, second)
import Models exposing (ApplicationState)
import Models.Types exposing (StatusLevel(..))
import Msgs exposing (Msg(..))


andThenCmd : Cmd msg -> ( ApplicationState, Cmd msg ) -> ( ApplicationState, Cmd msg )
andThenCmd secondCmd ( model, firstCmd ) =
    ( model
    , Cmd.batch [ firstCmd, secondCmd ]
    )


getStatusMessageExpiryTime : StatusLevel -> Cmd Msg
getStatusMessageExpiryTime statusLevel =
    let
        duration =
            case statusLevel of
                None ->
                    0

                Debug ->
                    1 * hour

                Notice ->
                    2 * second

                Warning ->
                    2 * second

                PersistentWarning ->
                    24 * hour

                Error ->
                    5 * second
    in
        perform (\time -> StatusMessageExpiryTimeReceived (time + duration)) now
