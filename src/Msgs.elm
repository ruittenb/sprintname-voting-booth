module Msgs exposing (Msg(..))

import Authentication
import Control exposing (Control)
import Models.Types exposing (..)
import Models.Pokemon exposing (RemotePokedex)
import Models.Ratings exposing (UserVote, RemoteTeamRatings, RemoteUserRatings)


type Msg
    = PokedexLoaded RemotePokedex
    | TeamRatingsLoaded RemoteTeamRatings
    | UserRatingsLoaded RemoteUserRatings
    | UserRatingsSaved RemoteUserRatings
    | AuthenticationMsg Authentication.Msg
    | GenerationAndLetterChanged Int Char
    | GenerationChanged Int
    | LetterChanged Char
    | VariantChanged Int BrowseDirection
    | SearchPokemon String
    | DebounceSearchPokemon (Control Msg)
    | VoteForPokemon UserVote
