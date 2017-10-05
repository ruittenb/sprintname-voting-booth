module Msgs exposing (Msg(..))

--import Material

import RemoteData exposing (WebData)
import Models exposing (..)


type Msg
    = ChangeUser String
    | ChangeGeneration Int
    | ChangeLetter Char
    | OnLoadRatings (WebData TeamRatings)
    | OnLoadPokemon ( Int, WebData Pokemon )
    | VoteForPokemon UserVote



{-
   | OnSaveVote (WebData TeamRatings)
-}
