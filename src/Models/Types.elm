module Models.Types exposing (..)

{-|

    Models.Types is separate from Models in order to prevent
    the cyclic dependency Models -> Msgs -> Models.

    By taking these apart, the dependencies are now
    - Models -> Msgs -> Models.Types
    - Models -> Models.Types
-}


type alias SubPage =
    { generation : String
    , letter : Char
    }


{-|

    The currentRoute can be of type:
    - Default: uninitialized because an invalid route was encountered (should redirect to Browse)
    - Search : a string has been entered in the search box, search results are shown;
    - Browse : generation and letter have been selected, a page of results is shown.
      This type is subdivided into:
      - WithPeopleVotes    : displays a mask and popup with user votes;
      - WithPokemonRankings: displays a mask and popup with pokemon rankings;
      - Freely             : free browsing (no mask or popup).
-}
type BrowseMode
    = Freely
    | WithPeopleVotes
    | WithPokemonRankings
    | WithCopyright


type Route
    = Default
    | Search String
    | Browse BrowseMode SubPage


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
