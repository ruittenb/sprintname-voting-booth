module Constants.Database exposing (..)

import Models.Database exposing (FirebaseConfig)


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
