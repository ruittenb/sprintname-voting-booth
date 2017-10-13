module Msgs exposing (Msg(..))

import RemoteData exposing (WebData)
import Authentication
import Models exposing (..)


type Msg
    = OnLoadRatings (WebData TeamRatings)
    | OnSaveRatings (WebData UserRatings)
    | OnLoadPokedex (WebData Pokedex)
    | AuthenticationMsg Authentication.Msg
    | ChangeGeneration Int
    | ChangeLetter Char
    | ChangeVariant Int BrowseDirection
    | SearchPokemon String
    | VoteForPokemon UserVote
