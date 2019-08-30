module View exposing (view)

import Html exposing (Html, div)
import RemoteData exposing (..)
import View.Application exposing (title, applicationPane, functionPane)
import View.Pokemon exposing (pokemonCanvas)
import Models exposing (ApplicationState)
import Msgs exposing (Msg)


view : ApplicationState -> Html Msg
view state =
    let
        sections =
            [ title
            , applicationPane state
            ]
                ++ case state.settings of
                    RemoteData.Success settings ->
                        if (not settings.maintenanceMode) then
                            [ functionPane state
                            , pokemonCanvas state
                            ]
                        else
                            []

                    _ ->
                        []
    in
        div [] sections
