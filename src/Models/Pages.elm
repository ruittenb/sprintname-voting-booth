module Models.Pages exposing
    ( Winner
    , RemotePages
    , Pages
    , Page
    , PortCompatiblePage
    )

import RemoteData exposing (RemoteData)


type alias Winner =
    Maybe
        { number : Int
        , name : String
        }

type alias Page =
    { id: Int
    , generation : Int
    , letter : Char
    , open : Bool
    , winnerNum : Maybe Int
    , winnerName : Maybe String
    , startDate : Maybe String
    }


type alias PortCompatiblePage =
    { id: Int
    , generation : Int
    , letter : String
    , open : Bool
    , winnerNum : Maybe Int
    , winnerName : Maybe String
    , startDate : Maybe String
    }


type alias Pages =
    List Page


type alias RemotePages =
    RemoteData String Pages
