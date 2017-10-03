module Msgs exposing (..)

import Http


--import Material
--import RemoteData exposing (WebData)

import Models exposing (..)


type Msg
    = VoteForPokemon UserVote
    | OnLoadRatings (Result String TeamRatingsJson)
    | ChangeGeneration Int
    | ChangeLetter Char
    | OnLoadPokemon Pokemon



{-
   | OnSaveVotes (Result Http.Error Cart)
   | Mdl (Material.Msg Msg)
-}
