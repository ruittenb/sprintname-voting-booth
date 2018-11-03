module Helpers.Authentication exposing (..)

import RemoteData exposing (WebData, RemoteData(..))
import Models.Auth exposing (UserProfile)
import Models.Authentication exposing (AuthenticationModel, AuthenticationState(..))
import Models.Ratings exposing (RemoteTeamRatings)


getUserNameForAuthModel : RemoteTeamRatings -> AuthenticationModel -> Maybe String
getUserNameForAuthModel ratings authModel =
    let
        userEmail =
            tryGetUserProfile authModel
                |> Maybe.map .email
    in
        case ratings of
            Success teamRatings ->
                teamRatings
                    |> List.filter
                        (\r ->
                            userEmail == Just r.email && r.active == True
                        )
                    |> List.map .userName
                    |> List.head

            _ ->
                Nothing


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
