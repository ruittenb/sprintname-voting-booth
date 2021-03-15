module Update.Authentication exposing (updateAuthWithNoProfile, updateAuthWithProfile)

import Helpers exposing (clearWarningMessage, setStatusMessage)
import Helpers.Authentication exposing (getUserNameForAuthModel)
import Models exposing (..)
import Models.Auth exposing (LoggedInUser)
import Models.Authentication exposing (AuthenticationModel, AuthenticationState(..))
import Models.Types exposing (StatusLevel(..))
import Msgs exposing (Msg)


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
                , currentUser = getUserNameForAuthModel oldState.ratings newAuthModel
            }
    in
    ( newState, cmd )
        |> clearWarningMessage


updateAuthWithNoProfile : ApplicationState -> Maybe String -> ( ApplicationState, Cmd Msg )
updateAuthWithNoProfile oldState possibleError =
    let
        ( newAuthModel, cmd ) =
            logout oldState.authModel

        newState =
            { oldState
                | authModel = newAuthModel
                , currentUser = Nothing
            }
    in
    case possibleError of
        Just error ->
            ( newState, cmd )
                |> setStatusMessage Error error

        Nothing ->
            ( newState, cmd )
                |> clearWarningMessage
