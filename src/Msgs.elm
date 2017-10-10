module Msgs exposing (Msg(..))

import RemoteData exposing (WebData)
import Models exposing (..)


type Msg
    = OnLoadRatings (WebData TeamRatings)
    | OnSaveRatings (WebData UserRatings)
    | OnLoadPokedex (WebData Pokedex)
    | ChangeUser String
    | ChangeGeneration Int
    | ChangeLetter Char
    | ChangeVariant Int BrowseDirection
    | SearchPokemon String
    | VoteForPokemon UserVote
