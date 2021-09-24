module Main exposing (main)

import Commands exposing (getTodayTimeCmd)
import Commands.Authentication exposing (decodeUser)
import Commands.Database exposing (firebaseInit, firebaseLoginWithJwtToken)
import Commands.Pages exposing (decodePage, decodePages)
import Commands.Pokemon exposing (decodePokedex)
import Commands.Ratings exposing (decodeTeamRatings, decodeUserRatings)
import Commands.Settings exposing (decodeSettings)
import Control
import Json.Encode as Encode exposing (Value)
import Models exposing (ApplicationState)
import Models.Authentication as Authentication exposing (AuthenticationState(..))
import Models.Types exposing (BrowseMode(..), Route(..), StatusLevel(..))
import Msgs exposing (Msg(..))
import Navigation exposing (Location, newUrl, programWithFlags)
import Ports
    exposing
        ( onAuthenticationFailed
        , onAuthenticationReceived
        , onFirebaseLoginFailed
        , onLoadPage
        , onLoadPages
        , onLoadPokedex
        , onLoadSettings
        , onLoadTeamRatings
        , onLoadUserRatings
        )
import RemoteData exposing (RemoteData(..))
import Result
import Routing exposing (createBrowsePath, parseLocation)
import Time exposing (millisecond, second)
import Update exposing (update)
import View exposing (view)


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

        currentRoute =
            parseLocation location

        ( initialSubpage, initialQuery, urlCmd ) =
            case currentRoute of
                Browse mode subPage ->
                    let
                        urlString =
                            createBrowsePath mode subPage.generation subPage.letter
                    in
                    ( Just subPage, "", newUrl urlString )

                Search _ query ->
                    ( Nothing, query, getTodayTimeCmd )

                Default ->
                    ( Nothing, "", getTodayTimeCmd )

        initialState : ApplicationState
        initialState =
            { authModel = authModel
            , currentUser = Nothing
            , highlightedUserId = Nothing
            , currentRoute = currentRoute
            , subPage = initialSubpage
            , query = initialQuery
            , todayDate = Nothing
            , settings = RemoteData.NotAsked
            , pokedex = RemoteData.NotAsked
            , pages = RemoteData.NotAsked
            , ratings = RemoteData.NotAsked
            , debounceState = Control.initialState
            , statusMessage = "Loading..."
            , statusLevel = Notice
            , statusExpiryTime = Nothing
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
        , onLoadPages (decodePages >> Msgs.PagesLoaded)
        , onLoadPage (decodePage >> Msgs.PageLoaded)
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
