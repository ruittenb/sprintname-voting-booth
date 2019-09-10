module Helpers
    exposing
        ( romanNumeral
        , setStatusMessage
        , clearStatusMessage
        , clearWarningMessage
        )

import Array exposing (Array)
import Msgs exposing (Msg(..))
import Models exposing (ApplicationState, StatusReporter)
import Models.Types exposing (StatusLevel(..))
import Commands exposing (getStatusMessageExpiryTime)


romanNumerals : Array String
romanNumerals =
    Array.fromList [ "O", "I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X" ]


romanNumeral : Int -> String
romanNumeral i =
    Array.get i romanNumerals
        |> Maybe.withDefault "?"


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
    if (state.statusLevel == Warning) then
        ( state, cmd )
            |> clearStatusMessage
    else
        ( state, cmd )
