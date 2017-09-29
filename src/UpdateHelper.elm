module UpdateHelper exposing (..)


numberBetween : Int -> Int -> Int -> Bool
numberBetween min max value =
    if min <= value && value <= max then
        True
    else
        False
