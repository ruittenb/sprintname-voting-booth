module Models.Types exposing (..)


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
