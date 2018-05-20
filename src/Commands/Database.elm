module Commands.Database exposing (firebaseInit, firebaseLogin, firebaseLogout)

import Constants.Database exposing (..)
import Models.Auth exposing (Token)
import Ports


firebaseInit : Cmd msg
firebaseInit =
    Ports.firebaseInit firebaseConfig


firebaseLogin : Token -> Cmd msg
firebaseLogin token =
    Ports.firebaseLogin token


firebaseLogout : Cmd msg
firebaseLogout =
    Ports.firebaseLogout ()
