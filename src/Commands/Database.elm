module Commands.Database
    exposing
        ( firebaseInit
        , firebaseLoginWithJwtToken
        , firebaseLoginWithFirebaseToken
        , firebaseLogout
        )

import Constants.Database exposing (..)
import Models.Auth exposing (Token)
import Ports


firebaseInit : Cmd msg
firebaseInit =
    Ports.firebaseInit firebaseConfig


firebaseLoginWithFirebaseToken : Token -> Cmd msg
firebaseLoginWithFirebaseToken token =
    Ports.firebaseLoginWithFirebaseToken token


firebaseLoginWithJwtToken : Token -> Cmd msg
firebaseLoginWithJwtToken token =
    Ports.firebaseLoginWithJwtToken token


firebaseLogout : Cmd msg
firebaseLogout =
    Ports.firebaseLogout ()
