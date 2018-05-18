module Main exposing (main)

import Control
import Result
import Navigation exposing (programWithFlags, Location)
import RemoteData exposing (RemoteData(..))
import Json.Encode as Encode exposing (Value)
import Constants exposing (initialGeneration, initialLetter)
import Constants.Authentication exposing (auth0Options)
import Msgs exposing (Msg(..))
import Models exposing (ApplicationState)
import Models.Types exposing (StatusLevel(None), ViewMode(..))
import Models.Authentication as Authentication
import View exposing (view)
import Update exposing (update, dissectLocationHash, hashToMsg)
import Commands.Authentication exposing (decodeUser)
import Commands.Pokemon exposing (decodePokedex)
import Commands.Ratings exposing (decodeTeamRatings, decodeUserRatings)
import Ports
    exposing
        ( auth0ShowLock
        , auth0Logout
        , onAuthenticationReceived
        , onAuth0Logout
        , onLoadPokedex
        , onLoadTeamRatings
        , onLoadUserRatings
        )


init : Value -> Location -> ( ApplicationState, Cmd Msg )
init credentials location =
    let
        storedUser =
            decodeUser credentials
                |> Result.toMaybe

        authModel =
            Authentication.init auth0ShowLock auth0Logout auth0Options storedUser

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
        ( initialState
        , Cmd.none
          -- |> andThenCmd firebaseAuthUpdate
        )


subscriptions : ApplicationState -> Sub Msg
subscriptions _ =
    Sub.batch
        --, Time.every second Tick
        [ onAuthenticationReceived (decodeUser >> Msgs.AuthenticationReceived)

        --        , onAuth0Logout (\() -> Msgs.AuthenticationMsg Authentication.LogOut)
        , onLoadPokedex (decodePokedex >> Msgs.PokedexLoaded)
        , onLoadTeamRatings (decodeTeamRatings >> Msgs.TeamRatingsLoaded)
        , onLoadUserRatings (decodeUserRatings >> Msgs.UserRatingsLoaded)
        ]


main : Program Value ApplicationState Msg
main =
    Navigation.programWithFlags
        hashToMsg
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
