module Helpers exposing (romanNumeral, setStatusMessage)

import Array exposing (Array)
import Msgs exposing (Msg(..))
import Models exposing (ApplicationState, StatusReporter)
import Models.Types exposing (StatusLevel(..))
import Commands exposing (getStatusMessageExpiryTime)


romanNumerals : Array String
romanNumerals =
    Array.fromList [ "O", "I", "II", "III", "IV", "V", "VI", "VII", "VIII" ]


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
