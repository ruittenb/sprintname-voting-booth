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
    - Default                    : uninitialized because an invalid route was encountered (should redirect to BFreely)
    - Browse BFreely             : generation and letter have been selected, a page of pokemon is shown;
    - Browse BWithPeopleVotes    : browse mode with mask and popup with user votes;
    - Browse BWithPokemonRankings: browse mode with mask and popup with pokemon rankings;
    - Browse BWithCopyright      : browse mode with mask and popup with copyright messages;
    - Search SFreely             : a string has been entered in the search box, search results are shown;
    - Search SWithCopyright      : search mode with mask and popup with copyright messages.
-}

type BrowseMode
    = BFreely
    | BWithPeopleVotes
    | BWithPokemonRankings
    | BWithCopyright

type SearchMode
    = SFreely
    | SWithCopyright


type Route
    = Default
    | Browse BrowseMode SubPage
    | Search SearchMode String


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
