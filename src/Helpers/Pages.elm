module Helpers.Pages exposing (isPageLocked, getCurrentPage, getWinner)

import List
import Maybe
import RemoteData exposing (WebData, RemoteData(..))
import Models.Types exposing (..)
import Models.Pages exposing (..)


isPageLocked : Route -> Page -> Bool
isPageLocked route page =
    case route of
        Search _ ->
            -- in Search mode, the view is always locked
            True

        _ ->
            -- in Browse mode: consider whether the current page is open
            not page.open


getCurrentPage : RemotePages -> Int -> Char -> Page
getCurrentPage remotePages generation letter =
    let
        defaultPage =
            { id = -1
            , generation = generation
            , letter = letter
            , open = False
            , winnerName = Nothing
            , winnerNum = Nothing
            , startDate = Nothing
            }
    in
        remotePages
            |> RemoteData.map
                (\pages ->
                    pages
                        |> List.filter (\page -> page.generation == generation)
                        |> List.filter (\page -> page.letter == letter)
                        |> List.head
                        |> Maybe.withDefault defaultPage
                )
            |> RemoteData.withDefault defaultPage


getWinner : Page -> Winner
getWinner page =
    Maybe.map2
        (\name number ->
            { name = name
            , number = number
            }
        )
        page.winnerName
        page.winnerNum
