module Main exposing (..)

import Html exposing (..)
import View exposing (..)
import Models exposing (..)
import Update exposing (..)
import Msgs exposing (Msg)


init : ( ApplicationState, Cmd Msg )
init =
    ( initialState, Cmd.none )


subscriptions : ApplicationState -> Sub Msg
subscriptions state =
    Sub.none


main : Program Never ApplicationState Msg
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
