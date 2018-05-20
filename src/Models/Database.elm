module Models.Database exposing (FirebaseConfig, FirebaseLoginParameters)

import Models.Auth exposing (Token)


type alias FirebaseConfig =
    { apiKey : String
    , databaseURL : String
    , authDomain : String
    , storageBucket : String
    , messagingSenderId : String
    }


type alias FirebaseLoginParameters =
    ( Token, FirebaseConfig )
