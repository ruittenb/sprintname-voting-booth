module Msgs exposing (..)

--import Material

import RemoteData exposing (WebData)
import Models exposing (..)


type Msg
    = VoteForPokemon UserVote
    | OnLoadRatings (WebData TeamRatings)
    | ChangeUser String
    | ChangeGeneration Int
    | ChangeLetter Char
    | OnLoadPokemon Pokemon



{-
   | OnSaveVotes (Result Http.Error Cart)
   | Mdl (Material.Msg Msg)
-}
