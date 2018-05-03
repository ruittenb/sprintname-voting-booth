module Update.Authentication exposing (updateAuthWithNoProfile, updateAuthWithProfile)

import Models.Types exposing (StatusLevel(..))
import Models.Auth exposing (LoggedInUser)
import Models.Authentication exposing (AuthenticationModel, AuthenticationState(..))
import Models exposing (..)
import Msgs exposing (Msg)
import Helpers exposing (getUserNameForAuthModel)


login : AuthenticationModel -> LoggedInUser -> ( AuthenticationModel, Cmd Msg )
login authModel userData =
    ( { authModel | state = LoggedIn userData }
    , Cmd.none
    )


logout : AuthenticationModel -> ( AuthenticationModel, Cmd Msg )
logout authModel =
    ( { authModel | state = LoggedOut }
    , authModel.logOut ()
    )


updateAuthWithProfile : ApplicationState -> LoggedInUser -> ( ApplicationState, Cmd Msg )
updateAuthWithProfile oldState userData =
    let
        ( newAuthModel, cmd ) =
            login oldState.authModel userData

        newState =
            { oldState
                | authModel = newAuthModel
                , statusMessage = ""
                , statusLevel = None
                , user = getUserNameForAuthModel oldState.ratings newAuthModel
            }
    in
        ( newState, cmd )


updateAuthWithNoProfile : ApplicationState -> Maybe String -> ( ApplicationState, Cmd Msg )
updateAuthWithNoProfile oldState possibleError =
    let
        ( newAuthModel, cmd ) =
            logout oldState.authModel

        newState =
            case possibleError of
                Just error ->
                    { oldState
                        | authModel = newAuthModel
                        , statusMessage = error
                        , statusLevel = Error
                        , user = Nothing
                    }

                Nothing ->
                    { oldState
                        | authModel = newAuthModel
                        , statusMessage = ""
                        , statusLevel = None
                        , user = Nothing
                    }
    in
        ( newState, cmd )
