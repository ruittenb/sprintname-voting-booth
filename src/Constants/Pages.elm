module Constants.Pages exposing (..)

import Constants exposing (..)
import Models.Pages exposing (Page)


defaultPage : Page
defaultPage =
    { id = -1
    , generation = 1
    , letter = 'A'
    , open = False
    , winnerNum = Nothing
    , winnerName = Nothing
    , startDate = Nothing
    }
