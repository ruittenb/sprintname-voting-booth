module Msgs exposing (Msg(..))

import Authentication
import Control exposing (Control)
import Models.Types exposing (..)
import Models.Pokemon exposing (RemotePokedex)
import Models.Ratings exposing (UserVote, RemoteTeamRatings, RemoteUserRatings)


{-
   Messages should be formulated in terms of things that happened, see:
   https://gist.github.com/Chadtech/89d9e085c3c5bf79602cceb53fbd6e31
-}


type Msg
    = AuthenticationMsg Authentication.Msg
    | PokedexLoaded RemotePokedex
    | TeamRatingsLoaded RemoteTeamRatings
    | UserRatingsLoaded RemoteUserRatings
    | UserRatingsSaved RemoteUserRatings
    | GenerationAndLetterChanged Int Char
    | GenerationChanged Int
    | LetterChanged Char
    | VariantChanged Int BrowseDirection
    | SearchPokemon String
    | DebounceSearchPokemon (Control Msg)
    | PokemonVoteCast UserVote
