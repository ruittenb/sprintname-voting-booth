module Msgs exposing (Msg(..))

import Authentication
import Control exposing (Control)
import Models.Types exposing (..)
import Models.Pokemon exposing (RemotePokedex)
import Models.Ratings exposing (UserVote, RemoteTeamRatings, RemoteUserRatings)


type Msg
    = OnLoadPokedex RemotePokedex
    | OnLoadUser RemoteUserRatings
    | OnLoadRatings RemoteTeamRatings
    | OnSaveRatings RemoteUserRatings
    | AuthenticationMsg Authentication.Msg
    | ChangeGenerationAndLetter Int Char
    | ChangeGeneration Int
    | ChangeLetter Char
    | ChangeVariant Int BrowseDirection
    | SearchPokemon String
    | DebounceSearchPokemon (Control Msg)
    | VoteForPokemon UserVote
