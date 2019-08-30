module View exposing (view)

import Html exposing (Html, div)
import RemoteData exposing (..)
import View.Application exposing (title, applicationPane, functionPane)
import View.Pokemon exposing (pokemonCanvas)
import Models exposing (ApplicationState)
import Msgs exposing (Msg)


alwaysPanes : ApplicationState -> List (Html Msg)
alwaysPanes state =
    [ title
    , applicationPane state
    ]


onlinePanes : ApplicationState -> List (Html Msg)
onlinePanes state =
    [ functionPane state
    , pokemonCanvas state
    ]


getPanes : ApplicationState -> List (Html Msg)
getPanes state =
    case state.settings of
        RemoteData.Success settings ->
            if (settings.maintenanceMode) then
                -- Success, maintenance mode
                []
            else
                -- Success, no maintenance mode
                onlinePanes state

        RemoteData.Failure error ->
            -- Failure: assume the worst
            []

        _ ->
            -- NotAsked, Loading: assume no maintenance
            onlinePanes state


view : ApplicationState -> Html Msg
view state =
    div []
        (alwaysPanes state ++ getPanes state)
