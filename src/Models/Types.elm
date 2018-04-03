module Models.Types exposing (..)

{-|

    Models.Types is separate from Models in order to prevent
    the cyclic dependency Models -> Msgs -> Models.

    By taking these apart, the dependencies are now
    Models -> Msgs -> Models.Types
    Models -> Models.Types
-}


type BrowseDirection
    = Next
    | Prev


type ViewMode
    = Search
    | Browse


type StatusLevel
    = Error
    | Warning
    | Notice
    | Debug
    | None
