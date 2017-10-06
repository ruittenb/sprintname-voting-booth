module Msgs exposing (Msg(..))

import RemoteData exposing (WebData)
import Models exposing (..)


type Msg
    = OnLoadRatings (WebData TeamRatings)
    | OnLoadPokedex (WebData Pokedex)
    | ChangeUser String
    | ChangeGeneration Int
    | ChangeLetter Char
    | VoteForPokemon UserVote



--   | OnSaveVote (WebData TeamRatings)
