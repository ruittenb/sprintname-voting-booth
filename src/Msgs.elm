module Msgs exposing (Msg(..))

import RemoteData exposing (WebData)
import Authentication
import Control exposing (Control)
import Models.Types exposing (..)
import Models.Pokedex exposing (Pokedex)
import Models.Ratings exposing (UserVote, TeamRatings, UserRatings)


type Msg
    = OnLoadRatings (WebData TeamRatings)
    | OnSaveRatings (WebData UserRatings)
    | OnLoadPokedex (WebData Pokedex)
    | AuthenticationMsg Authentication.Msg
    | ChangeGenerationAndLetter Int Char
    | ChangeGeneration Int
    | ChangeLetter Char
    | ChangeVariant Int BrowseDirection
    | SearchPokemon String
    | DebounceSearchPokemon (Control Msg)
    | VoteForPokemon UserVote
