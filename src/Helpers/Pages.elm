module Helpers.Pages exposing (getCurrentPage, getDefaultPageForToday, getWinner, isPageLocked)

import Date exposing (Date)
import Date.Extra exposing (toIsoString)
import List
import Maybe
import Models.Pages exposing (..)
import Models.Types exposing (..)
import RemoteData exposing (RemoteData(..), WebData)


getFirstOpenPage : RemotePages -> String -> Maybe Page
getFirstOpenPage remotePages referenceDate =
    remotePages
        |> RemoteData.toMaybe
        |> Maybe.andThen
            (\pages ->
                pages
                    |> List.filter
                        (.startDate
                            -- find pages with startdate in future. comparing as strings
                            -- is probably faster than comparing dates and is good enough
                            -- as we are only interested in a 1-day resolution
                            >> Maybe.map ((<) referenceDate)
                            -- the page must have a startdate
                            >> Maybe.withDefault False
                        )
                    |> List.sortBy (.startDate >> Maybe.withDefault "")
                    |> List.head
            )


getDefaultPageForToday : RemotePages -> Date -> Maybe Page
getDefaultPageForToday remotePages today =
    let
        todayAsIsoString =
            toIsoString today
    in
    getFirstOpenPage remotePages todayAsIsoString


-- in Search and Default mode, the view is always locked.
-- in Browse mode: consider whether the current page is open


isPageLocked : Route -> Maybe Page -> Bool
isPageLocked route maybePage =
    case route of
        Browse _ _ ->
            maybePage
                |> Maybe.map (.open >> not)
                |> Maybe.withDefault True

        Search _ _ ->
            True

        Default ->
            True


getCurrentPage : RemotePages -> Maybe SubPage -> Maybe Page
getCurrentPage remotePages maybeSubPage =
    remotePages
        |> RemoteData.toMaybe
        |> Maybe.andThen
            (\pages ->
                maybeSubPage
                    |> Maybe.andThen
                        (\subPage ->
                            pages
                                |> List.filter (\page -> page.generation == subPage.generation)
                                |> List.filter (\page -> page.letter == subPage.letter)
                                |> List.head
                        )
            )


getWinner : Maybe Page -> Winner
getWinner page =
    page
        |> Maybe.andThen
            (\actualPage ->
                Maybe.map2
                    (\name pokemonId ->
                        -- TODO replace this function with PokeWinner constructor?
                        { name = name
                        , pokemonId = pokemonId
                        }
                    )
                    actualPage.winnerName
                    actualPage.winnerId
            )
