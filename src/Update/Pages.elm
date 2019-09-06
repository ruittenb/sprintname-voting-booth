module Update.Pages exposing (updatePageLockState)

import RemoteData exposing (RemoteData(..))
import Constants exposing (..)
import Models exposing (..)
import Models.Pages exposing (..)
import Msgs exposing (Msg(..))
import Commands.Pages exposing (savePageLockState)


updatePageLockState : ApplicationState -> Page -> ( ApplicationState, Cmd Msg )
updatePageLockState oldState page =
    let
        newPages =
            oldState.pages
                |> RemoteData.map
                    (List.map
                        (\oldPage ->
                            if
                                (oldPage.generation == page.generation)
                                    && (oldPage.letter == page.letter)
                            then
                                { page | open = not page.open }

                            else
                                oldPage
                        )
                    )

        newState =
            { oldState | pages = newPages }
    in
        ( newState
        , savePageLockState page
        )
