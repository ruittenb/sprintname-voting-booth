module Models.Pages exposing (Pages)


type alias Page =
    { generation : Int
    , letter : Char
    , open : Bool
    , winnerNum : Maybe Int
    , winnerName : Maybe String
    }


type alias Dated x =
    { x | startDate : Date }


type alias StringDated x =
    { x | startDateString : String }
