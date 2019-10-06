module Models.Types exposing (..)

{-|

    Models.Types is separate from Models in order to prevent
    the cyclic dependency Models -> Msgs -> Models.

    By taking these apart, the dependencies are now
    - Models -> Msgs -> Models.Types
    - Models -> Models.Types
-}


type alias Subpage =
    { generation : Int
    , letter : Char
    }


type Mask
    = WithoutMask
    | WithPeopleVotes
    | WithPokemonRankings


type Route
    = Browse Mask Subpage
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
