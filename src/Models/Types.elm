module Models.Types exposing (..)

{-|

    Models.Types is separate from Models in order to prevent
    the cyclic dependency Models -> Msgs -> Models.

    By taking these apart, the dependencies are now
    - Models -> Msgs -> Models.Types
    - Models -> Models.Types
-}


type alias SubPage =
    { generation : Int
    , letter : Char
    }


type Route
    = Browse SubPage
    | BrowseWithPeopleVotes SubPage
    | BrowseWithPokemonRankings SubPage
    | Search String


type BrowseDirection
    = Next
    | Prev


type StatusLevel
    = Error
    | Maintenance
    | Warning
    | Notice
    | Debug
    | None
