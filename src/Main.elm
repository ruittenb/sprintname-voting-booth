module Main exposing (main)

import Html
import Models exposing (ApplicationState, initialState)
import View exposing (view)
import Update exposing (update)
import Msgs exposing (Msg)
import Commands exposing (loadAll)


init : ( ApplicationState, Cmd Msg )
init =
    ( initialState, loadAll )


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
