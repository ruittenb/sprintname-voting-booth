module Msgs exposing (Msg(..))

import Control exposing (Control)
import Models.Types exposing (..)
import Models.Auth exposing (RemoteLoggedInUser)
import Models.Pokemon exposing (RemotePokedex)
import Models.Ratings exposing (RemoteTeamRatings, RemoteUserRatings, UserVote)


{-
   Messages should be formulated in terms of things that happened, see:
   https://gist.github.com/Chadtech/89d9e085c3c5bf79602cceb53fbd6e31
-}


type Msg
    = AuthenticationReceived RemoteLoggedInUser
    | AuthenticationFailed String
    | FirebaseLoginFailed String
    | AuthenticationLoginClicked
    | AuthenticationLogoutClicked
    | PokedexLoaded RemotePokedex
    | TeamRatingsLoaded RemoteTeamRatings
    | UserRatingsLoaded RemoteUserRatings
    | UserRatingsSaved RemoteUserRatings
    | GenerationAndLetterChanged Int Char
    | VariantChanged Int BrowseDirection
    | SearchPokemon String
    | DebounceSearchPokemon (Control Msg)
    | PokemonVoteCast UserVote
