module Commands exposing (loadAll)

import Msgs exposing (Msg)
import Commands.Ratings exposing (loadRatings)


loadAll : Cmd Msg
loadAll =
    loadRatings
