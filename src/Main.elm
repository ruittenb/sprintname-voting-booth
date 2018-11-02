module Main exposing (main)

import Control
import Result
import Time exposing (second)
import Navigation exposing (programWithFlags, Location)
import RemoteData exposing (RemoteData(..))
import Json.Encode as Encode exposing (Value)
import Constants exposing (initialGeneration, initialLetter)
import Msgs exposing (Msg(..))
import Routing exposing (parseLocation)
import Models exposing (ApplicationState)
import Models.Types exposing (StatusLevel(None), Route(..))
import Models.Authentication as Authentication exposing (AuthenticationState(..))
import View exposing (view)
import Update exposing (update)
import Commands.Authentication exposing (decodeUser)
import Commands.Database exposing (firebaseInit, firebaseLoginWithJwtToken)
import Commands.Pokemon exposing (decodePokedex)
import Commands.Ratings exposing (decodeTeamRatings, decodeUserRatings)
import Ports
    exposing
        ( onAuthenticationReceived
        , onAuthenticationFailed
        , onFirebaseLoginFailed
        , onLoadPokedex
        , onLoadTeamRatings
        , onLoadUserRatings
        )


init : Value -> Location -> ( ApplicationState, Cmd Msg )
init credentials location =
    let
        authModel =
            decodeUser credentials
                |> Result.toMaybe
                |> Authentication.init

        cmd =
            case authModel.state of
                LoggedIn userData ->
                    Cmd.batch
                        [ firebaseInit
                        , firebaseLoginWithJwtToken userData.idToken
                        ]

                LoggedOut ->
                    firebaseInit

        emptyPreloaded =
            { generations = []
            , letters = []
            }

        defaultSubpage =
            { generation = initialGeneration
            , letter = initialLetter
            }

        currentRoute =
            parseLocation location
                |> Maybe.withDefault (Browse defaultSubpage)

        ( initialSubpage, initialQuery ) =
            case currentRoute of
                Search query ->
                    ( defaultSubpage, query )

                Browse subpage ->
                    ( subpage, "" )

                BrowseWithPeopleVotes subpage ->
                    ( subpage, "" )

                BrowseWithPokemonRankings subpage ->
                    ( subpage, "" )

        initialState : ApplicationState
        initialState =
            { authModel = authModel
            , currentUser = Nothing
            , statusMessage = ""
            , statusLevel = None
            , debounceState = Control.initialState
            , currentRoute = currentRoute
            , generation = initialSubpage.generation
            , letter = initialSubpage.letter
            , preloaded = emptyPreloaded
            , query = initialQuery
            , pokedex = RemoteData.NotAsked
            , ratings = RemoteData.NotAsked
            }
    in
        ( initialState, cmd )


subscriptions : ApplicationState -> Sub Msg
subscriptions _ =
    Sub.batch
        [ Time.every (2 * second) Tick
        , onAuthenticationReceived (decodeUser >> Msgs.AuthenticationReceived)
        , onAuthenticationFailed Msgs.AuthenticationFailed
        , onFirebaseLoginFailed (.message >> Msgs.FirebaseLoginFailed)
        , onLoadPokedex (decodePokedex >> Msgs.PokedexLoaded)
        , onLoadTeamRatings (decodeTeamRatings >> Msgs.TeamRatingsLoaded)
        , onLoadUserRatings (decodeUserRatings >> Msgs.UserRatingsLoaded)
        ]


main : Program Value ApplicationState Msg
main =
    Navigation.programWithFlags
        (parseLocation >> UrlChanged)
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
