module Helpers.Application exposing (getIsCurrentUserAdmin)

import RemoteData exposing (WebData, RemoteData(..))
import Helpers.Pokemon exposing (extractOneUserFromRatings)
import Models exposing (..)


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
