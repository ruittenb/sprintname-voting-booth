module UpdateHelper exposing (..)


numberBetween : Number -> Number -> Number -> Bool
numberBetween min max value =
    if min <= value && value <= max then
        True
    else
        False
