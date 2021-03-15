module Update.Pages exposing (updatePageLockState, updatePageWithWinner)

import Commands.Pages exposing (savePageState)
import Constants exposing (..)
import Models exposing (..)
import Models.Pages exposing (..)
import Models.Pokemon exposing (PokeWinner)
import Msgs exposing (Msg(..))
import RemoteData exposing (RemoteData(..))


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
            if page.winnerId == Just winner.pokemonId then
                { page
                    | winnerName = Nothing
                    , winnerId = Nothing
                }

            else
                { page
                    | winnerName = Just winner.name
                    , winnerId = Just winner.pokemonId
                }

        newPages =
            updatePageData oldState.pages newPage

        newState =
            { oldState | pages = newPages }
    in
    ( newState
    , savePageState newPage
    )
