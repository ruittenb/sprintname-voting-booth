module Commands exposing (..)

import Models exposing (ApplicationState)
import Models.Types exposing (StatusLevel(..))
import Msgs exposing (Msg(..))
import Task exposing (perform)
import Time exposing (hour, now, second)


andThenCmd : Cmd msg -> ( ApplicationState, Cmd msg ) -> ( ApplicationState, Cmd msg )
andThenCmd secondCmd ( model, firstCmd ) =
    ( model
    , Cmd.batch [ firstCmd, secondCmd ]
    )


butFirstCmd : Cmd msg -> ( ApplicationState, Cmd msg ) -> ( ApplicationState, Cmd msg )
butFirstCmd firstCmd ( model, secondCmd ) =
    ( model
    , Cmd.batch [ firstCmd, secondCmd ]
    )


getTodayTimeCmd : Cmd Msg
getTodayTimeCmd =
    perform TodayReceived now


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

                Maintenance ->
                    24 * hour

                Error ->
                    10 * second
    in
    perform (\time -> StatusMessageExpiryTimeReceived (time + duration)) now
