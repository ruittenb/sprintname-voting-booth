module Models.Pages exposing (RemotePages, Pages)

import Date exposing (Date)
import RemoteData exposing (RemoteData)


type alias Page =
    { generation : Int
    , letter : Char
    , open : Bool
    , winnerNum : Maybe Int
    , winnerName : Maybe String
    }


type alias Pages =
    List Page


type alias RemotePages =
    RemoteData String Pages


type alias Dated x =
    { x | startDate : Date }


type alias StringDated x =
    { x | startDateString : String }
