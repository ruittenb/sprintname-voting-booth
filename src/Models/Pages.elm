module Models.Pages exposing (..)

import Date exposing (Date)
import RemoteData exposing (RemoteData)


type alias Winner =
    Maybe
        { num : Int
        , name : String
        }


type alias Page =
    { generation : Int
    , letter : Char
    , open : Bool
    , winnerNum : Maybe Int
    , winnerName : Maybe String
    , startDate : Maybe String
    }


type alias Pages =
    List Page


type alias RemotePages =
    RemoteData String Pages
