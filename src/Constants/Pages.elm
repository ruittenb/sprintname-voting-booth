module Constants.Pages exposing (..)

import Constants exposing (..)
import Models.Pages exposing (Page)


defaultPage : Page
defaultPage =
    { id = -1
    , generation = "I"
    , letter = 'A'
    , open = False
    , winnerId = Nothing
    , winnerName = Nothing
    , startDate = Nothing
    }
