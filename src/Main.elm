module Main exposing (main)

import Html
import Auth0
import Authentication
import RemoteData exposing (RemoteData(..))
import Constants exposing (initialGeneration, initialLetter)
import Models exposing (ApplicationState, StatusLevel(None))
import Ports exposing (auth0showLock, auth0logout, auth0authResult)
import View exposing (view)
import Update exposing (update)
import Msgs exposing (Msg)
import Commands exposing (loadAll)


init : Maybe Auth0.LoggedInUser -> ( ApplicationState, Cmd Msg )
init initialUser =
    let
        authModel =
            Authentication.init auth0showLock auth0logout initialUser

        initialState : ApplicationState
        initialState =
            { authModel = authModel
            , user = Nothing
            , statusMessage = ""
            , statusLevel = None
            , generation = initialGeneration
            , letter = initialLetter
            , pokedex = RemoteData.NotAsked
            , ratings = RemoteData.NotAsked
            }
    in
        ( initialState, loadAll )


subscriptions : ApplicationState -> Sub Msg
subscriptions state =
    auth0authResult (Authentication.handleAuthResult >> Msgs.AuthenticationMsg)


main : Program (Maybe Auth0.LoggedInUser) ApplicationState Msg
main =
    Html.programWithFlags
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
