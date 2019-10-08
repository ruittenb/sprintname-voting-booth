module Helpers.Pages exposing (isPageLocked, getCurrentPage, getWinner)

import List
import Maybe
import RemoteData exposing (WebData, RemoteData(..))
import Models.Types exposing (..)
import Models.Pages exposing (..)


isPageLocked : Route -> Maybe Page -> Bool
isPageLocked route maybePage =
    case route of
        Search _ ->
            -- in Search mode, the view is always locked
            True

        _ ->
            -- in Browse mode: consider whether the current page is open
            Maybe.map (.open >> not) maybePage
                |> Maybe.withDefault True


getCurrentPage : RemotePages -> Maybe SubPage -> Maybe Page
getCurrentPage remotePages maybeSubPage =
    Maybe.map2
        (\pages subPage ->
            pages
                |> List.filter (\page -> page.generation == subPage.generation)
                |> List.filter (\page -> page.letter == subPage.letter)
                |> List.head
        )
        (RemoteData.toMaybe remotePages)
        maybeSubPage
        -- we might not have a current page.
        |> Maybe.withDefault Nothing


getWinner : Maybe Page -> Winner
getWinner page =
    page
        |> Maybe.map
            (\page ->
                (Maybe.map2
                    (\name number ->
                        { name = name
                        , number = number
                        }
                    )
                    page.winnerName
                    page.winnerNum
                )
            )
        |> Maybe.withDefault Nothing
