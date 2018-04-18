module Main exposing (main)

import Auth0
import Authentication
import Navigation exposing (programWithFlags, Location)
import RemoteData exposing (RemoteData(..))
import Control exposing (initialState)
import Constants exposing (initialGeneration, initialLetter)
import Msgs exposing (Msg)
import Models exposing (ApplicationState)
import Models.Types exposing (StatusLevel(None), ViewMode(..))
import View exposing (view)
import Update exposing (update, dissectLocationHash, hashToMsg)
import Commands.Pokemon exposing (decodePokedex)
import Commands.Ratings exposing (decodeTeamRatings, decodeUserRatings)
import Ports
    exposing
        ( auth0showLock
        , auth0logout
        , onAuthenticationResult
        , onLoadPokedex
        , onLoadTeamRatings
        , onLoadUserRatings
        )


init : Maybe Auth0.LoggedInUser -> Location -> ( ApplicationState, Cmd Msg )
init initialUser location =
    let
        authModel =
            Authentication.init auth0showLock auth0logout initialUser

        defaultSubpage =
            { generation = initialGeneration
            , letter = initialLetter
            }

        subpage =
            dissectLocationHash location defaultSubpage

        initialState : ApplicationState
        initialState =
            { authModel = authModel
            , user = Nothing
            , statusMessage = ""
            , statusLevel = None
            , debounceState = Control.initialState
            , viewMode = Browse
            , generation = subpage.generation
            , letter = subpage.letter
            , query = ""
            , pokedex = RemoteData.NotAsked
            , ratings = RemoteData.NotAsked
            }
    in
        ( initialState, Cmd.none )


subscriptions : ApplicationState -> Sub Msg
subscriptions _ =
    Sub.batch
        [ onAuthenticationResult (Authentication.handleAuthResult >> Msgs.AuthenticationMsg)
        , onLoadPokedex (decodePokedex >> Msgs.OnLoadPokedex)
        , onLoadTeamRatings (decodeTeamRatings >> Msgs.OnLoadTeamRatings)
        , onLoadUserRatings (decodeUserRatings >> Msgs.OnLoadUserRatings)
        ]


main : Program (Maybe Auth0.LoggedInUser) ApplicationState Msg
main =
    Navigation.programWithFlags
        hashToMsg
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
