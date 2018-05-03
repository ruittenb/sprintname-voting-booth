module Helpers.Authentication exposing (..)

import Models.Auth exposing (UserProfile)
import Models.Authentication exposing (AuthenticationModel, AuthenticationState(..))


tryGetUserProfile : AuthenticationModel -> Maybe UserProfile
tryGetUserProfile model =
    case model.state of
        LoggedIn user ->
            Just user.profile

        LoggedOut ->
            Nothing


isLoggedIn : AuthenticationModel -> Bool
isLoggedIn model =
    case model.state of
        LoggedIn _ ->
            True

        LoggedOut ->
            False
