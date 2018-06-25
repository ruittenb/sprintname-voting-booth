module Commands exposing (..)

import Models exposing (ApplicationState)


andThenCmd : Cmd msg -> ( ApplicationState, Cmd msg ) -> ( ApplicationState, Cmd msg )
andThenCmd secondCmd ( model, firstCmd ) =
    ( model
    , Cmd.batch [ firstCmd, secondCmd ]
    )
