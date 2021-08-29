module Models.Pages
    exposing
        ( Winner
        , RemotePages
        , RemotePage
        , Pages
        , Page
        , PortCompatiblePage
        )

import RemoteData exposing (RemoteData)


type alias Winner =
    Maybe
        { pokemonId : Int
        , name : String
        }


type alias Page =
    { id : Int
    , generation : String
    , letter : Char
    , open : Bool
    , winnerId : Maybe Int
    , winnerName : Maybe String
    , startDate : Maybe String
    }


type alias PortCompatiblePage =
    { id : Int
    , generation : String
    , letter : String
    , open : Bool
    , winnerId : Maybe Int
    , winnerName : Maybe String
    , startDate : Maybe String
    }


type alias Pages =
    List Page


type alias RemotePages =
    RemoteData String Pages


type alias RemotePage =
    RemoteData String Page
