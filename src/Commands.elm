module Commands exposing (..)

import Models exposing (ApplicationState)


andThenCmd : ( ApplicationState, Cmd msg ) -> Cmd msg -> ( ApplicationState, Cmd msg )
andThenCmd ( model, firstCmd ) secondCmd =
    ( model
    , Cmd.batch [ firstCmd, secondCmd ]
    )
