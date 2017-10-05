module Commands exposing (loadAll)

import Msgs exposing (Msg)
import CommandsRatings exposing (loadRatings)


loadAll : Cmd Msg
loadAll =
    loadRatings
