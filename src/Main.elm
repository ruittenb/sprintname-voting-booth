module Main exposing (main)

import Control
import Result
import Time exposing (millisecond)
import Navigation exposing (programWithFlags, Location, newUrl)
import RemoteData exposing (RemoteData(..))
import Json.Encode as Encode exposing (Value)
import Constants exposing (initialGeneration, initialLetter)
import Msgs exposing (Msg(..))
import Routing exposing (parseLocation, createBrowsePath)
import Models exposing (ApplicationState)
import Models.Types exposing (StatusLevel(None), Route(..))
import Models.Authentication as Authentication exposing (AuthenticationState(..))
import View exposing (view)
import Update exposing (update)
import Commands.Authentication exposing (decodeUser)
import Commands.Database exposing (firebaseInit, firebaseLoginWithJwtToken)
import Commands.Settings exposing (decodeSettings)
import Commands.Pokemon exposing (decodePokedex)
import Commands.Ratings exposing (decodeTeamRatings, decodeUserRatings)
import Ports
    exposing
        ( onAuthenticationReceived
        , onAuthenticationFailed
        , onFirebaseLoginFailed
        , onLoadSettings
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

        authCmd =
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

        ( initialSubpage, initialQuery, urlCmd ) =
            case currentRoute of
                Search query ->
                    ( defaultSubpage, query, Cmd.none )

                Browse subpage ->
                    ( subpage, "", newUrl <| createBrowsePath subpage.generation subpage.letter )

                BrowseWithPeopleVotes subpage ->
                    ( subpage, "", newUrl <| createBrowsePath subpage.generation subpage.letter )

                BrowseWithPokemonRankings subpage ->
                    ( subpage, "", newUrl <| createBrowsePath subpage.generation subpage.letter )

        initialState : ApplicationState
        initialState =
            { authModel = authModel
            , currentUser = Nothing
            , statusMessage = ""
            , statusLevel = None
            , statusExpiryTime = Nothing
            , debounceState = Control.initialState
            , currentRoute = currentRoute
            , generation = initialSubpage.generation
            , letter = initialSubpage.letter
            , preloaded = emptyPreloaded
            , query = initialQuery
            , settings = RemoteData.NotAsked
            , pokedex = RemoteData.NotAsked
            , ratings = RemoteData.NotAsked
            }
    in
        ( initialState
        , Cmd.batch [ authCmd, urlCmd ]
        )


subscriptions : ApplicationState -> Sub Msg
subscriptions _ =
    Sub.batch
        [ onAuthenticationReceived (decodeUser >> Msgs.AuthenticationReceived)
        , onAuthenticationFailed Msgs.AuthenticationFailed
        , onFirebaseLoginFailed (.message >> Msgs.FirebaseLoginFailed)
        , onLoadSettings (decodeSettings >> Msgs.SettingsLoaded)
        , onLoadPokedex (decodePokedex >> Msgs.PokedexLoaded)
        , onLoadTeamRatings (decodeTeamRatings >> Msgs.TeamRatingsLoaded)
        , onLoadUserRatings (decodeUserRatings >> Msgs.UserRatingsLoaded)
        , Time.every (500 * millisecond) Tick
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
