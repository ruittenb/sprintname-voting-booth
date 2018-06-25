module Models.Database exposing (FirebaseConfig, FirebaseLoginParameters, Diagnostics)

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


type alias Diagnostics =
    { message : String
    , status : Int
    }
