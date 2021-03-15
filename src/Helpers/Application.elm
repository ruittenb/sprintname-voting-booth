module Helpers.Application exposing (getIsCurrentUserAdmin)

import Helpers.Pokemon exposing (extractOneUserFromRatings)
import Models exposing (..)
import RemoteData exposing (RemoteData(..), WebData)


getIsCurrentUserAdmin : ApplicationState -> Bool
getIsCurrentUserAdmin state =
    let
        ( currentUserDataList, _ ) =
            state.ratings
                |> RemoteData.map
                    (\ratings -> extractOneUserFromRatings ratings state.currentUser)
                |> RemoteData.withDefault
                    ( [], [] )
    in
    List.head currentUserDataList
        |> Maybe.map .admin
        |> Maybe.withDefault False
