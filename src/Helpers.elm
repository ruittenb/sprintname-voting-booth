module Helpers exposing
    ( andThen2
    , clearStatusMessage
    , clearWarningMessage
    , setStatusMessage
    )

import Array exposing (Array)
import Commands exposing (getStatusMessageExpiryTime)
import Models exposing (ApplicationState, StatusReporter)
import Models.Types exposing (StatusLevel(..))
import Msgs exposing (Msg(..))


andThen2 : (a -> b -> Maybe c) -> Maybe a -> Maybe b -> Maybe c
andThen2 fn ma mb =
    case
        ( ma, mb )
    of
        ( Nothing, _ ) ->
            Nothing

        ( _, Nothing ) ->
            Nothing

        ( Just a, Just b ) ->
            fn a b


setStatusMessage : StatusLevel -> String -> ( StatusReporter x, Cmd Msg ) -> ( StatusReporter x, Cmd Msg )
setStatusMessage statusLevel statusMessage ( state, cmd ) =
    let
        nextCmd =
            if statusLevel == None then
                cmd

            else
                Cmd.batch
                    [ cmd
                    , getStatusMessageExpiryTime statusLevel
                    ]
    in
    ( { state
        | statusLevel = statusLevel
        , statusMessage = statusMessage
        , statusExpiryTime = Nothing
      }
    , nextCmd
    )


clearStatusMessage : ( StatusReporter x, Cmd Msg ) -> ( StatusReporter x, Cmd Msg )
clearStatusMessage ( state, cmd ) =
    ( state, cmd )
        |> setStatusMessage None ""


clearWarningMessage : ( StatusReporter x, Cmd Msg ) -> ( StatusReporter x, Cmd Msg )
clearWarningMessage ( state, cmd ) =
    if state.statusLevel == Warning then
        ( state, cmd )
            |> clearStatusMessage

    else
        ( state, cmd )
