module Msgs exposing (Msg(..))

import Control exposing (Control)
import Models.Auth exposing (RemoteLoggedInUser)
import Models.Pages exposing (Page, RemotePage, RemotePages)
import Models.Pokemon exposing (PokeWinner, RemotePokedex)
import Models.Ratings exposing (RemoteTeamRatings, RemoteUserRatings, UserVote)
import Models.Settings exposing (RemoteSettings)
import Models.Types exposing (..)
import Time exposing (Time)



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
    | SettingsLoaded RemoteSettings
    | PokedexLoaded RemotePokedex
    | PagesLoaded RemotePages
    | PageLoaded RemotePage
    | TeamRatingsLoaded RemoteTeamRatings
    | UserRatingsLoaded RemoteUserRatings
    | UserRatingsSaved RemoteUserRatings
    | UserHighlightClicked Int
    | VariantChanged Int BrowseDirection
    | UrlChanged Route
    | CloseMaskClicked
    | PageLockClicked Page
    | WinnerElected Page PokeWinner
    | MaintenanceModeClicked
    | SearchPokemon String
    | DebounceSearchPokemon (Control Msg)
    | PokemonVoteCast UserVote
    | TodayReceived Time
    | StatusMessageExpiryTimeReceived Time
    | Tick Time
