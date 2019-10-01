module Update.Pages exposing (updatePageLockState, updatePageWithWinner)

import RemoteData exposing (RemoteData(..))
import Constants exposing (..)
import Models exposing (..)
import Models.Pages exposing (..)
import Models.Pokemon exposing (PokeWinner)
import Msgs exposing (Msg(..))
import Commands.Pages exposing (savePageState)


updatePageData : RemotePages -> Page -> RemotePages
updatePageData pages newPage =
    pages
        |> RemoteData.map
            (List.map
                (\oldPage ->
                    if
                        (oldPage.generation == newPage.generation)
                            && (oldPage.letter == newPage.letter)
                    then
                        newPage
                    else
                        oldPage
                )
            )


updatePageLockState : ApplicationState -> Page -> ( ApplicationState, Cmd Msg )
updatePageLockState oldState page =
    let
        newPage =
            { page | open = not page.open }

        newPages =
            updatePageData oldState.pages newPage

        newState =
            { oldState | pages = newPages }
    in
        ( newState
        , savePageState newPage
        )


updatePageWithWinner : ApplicationState -> Page -> PokeWinner -> ( ApplicationState, Cmd Msg )
updatePageWithWinner oldState page winner =
    let
        newPage =
            { page
                | winnerName = Just winner.name
                , winnerNum = Just winner.number
                , open = False
            }

        newPages =
            updatePageData oldState.pages newPage

        newState =
            { oldState | pages = newPages }
    in
        ( newState
        , savePageState newPage
        )
