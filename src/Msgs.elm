module Msgs exposing (..)

--import Material

import RemoteData exposing (WebData)
import Models exposing (..)


type Msg
    = VoteForPokemon UserVote
    | OnLoadRatings (WebData TeamRatings)
    | OnLoadPokemon (WebData Pokemon)
    | ChangeUser String
    | ChangeGeneration Int
    | ChangeLetter Char



{-
   | OnSaveVote (WebData TeamRatings)
-}
