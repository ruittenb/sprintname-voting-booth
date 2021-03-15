module Constants.Database exposing (..)

import Models.Database exposing (FirebaseConfig)



{- The apiKey essentially just identifies your Firebase project on the Google servers.
   It is not a security risk for someone to know it. In fact, it is necessary for them
   to know it, in order for them to interact with your Firebase project.
   @see https://stackoverflow.com/questions/37482366/is-it-safe-to-expose-firebase-apikey-to-the-public
-}


firebaseApiKey : String
firebaseApiKey =
    "AIzaSyAm4--Q2MjVWGZYW-IC8LPZARXJq-XyHXA"


firebaseDatabaseURL : String
firebaseDatabaseURL =
    "https://sprintname-voting-booth.firebaseio.com"


firebaseAuthDomain : String
firebaseAuthDomain =
    "sprintname-voting-booth.firebaseapp.com"


firebaseStorageBucket : String
firebaseStorageBucket =
    "sprintname-voting-booth.appspot.com"


firebaseMessagingSenderId : String
firebaseMessagingSenderId =
    "90828432994"


firebaseConfig : FirebaseConfig
firebaseConfig =
    { apiKey = firebaseApiKey
    , databaseURL = firebaseDatabaseURL
    , authDomain = firebaseAuthDomain
    , storageBucket = firebaseStorageBucket
    , messagingSenderId = firebaseMessagingSenderId
    }
