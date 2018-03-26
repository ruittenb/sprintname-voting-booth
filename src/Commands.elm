module Commands exposing (loadAll)

import Msgs exposing (Msg)
import Commands.Ratings exposing (loadRatings)
import Commands.Pokemon exposing (loadPokedex)


loadAll : Cmd Msg
loadAll =
    Cmd.batch
        [ loadRatings
        , loadPokedex
        ]
