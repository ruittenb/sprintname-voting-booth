module Msgs exposing (..)

--import Http
--import Material
--import RemoteData exposing (WebData)

import Models exposing (..)


type Msg
    = VoteForPokemon UserVote
    | ChangeGeneration Int
    | ChangeLetter Char



{-
   | OnLoadPokemon (WebData Cart)
   | OnSaveVotes (Result Http.Error Cart)
   | Mdl (Material.Msg Msg)
-}
