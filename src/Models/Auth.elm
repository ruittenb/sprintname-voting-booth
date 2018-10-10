module Models.Auth exposing (..)

-- Auth0


type alias Token =
    String


type alias UserProfile =
    { sub : String
    , email : String
    , email_verified : Bool
    , given_name : String
    , family_name : String
    , nickname : String
    , name : String
    , picture : String
    , locale : String
    , updated_at : String
    }


type alias LoggedInUser =
    { idToken : Token
    , accessToken : Token
    , profile : UserProfile
    }


type alias RemoteLoggedInUser =
    Result String LoggedInUser


type alias AuthenticationError =
    { name : Maybe String
    , code : Maybe String
    , description : String
    , statusCode : Maybe Int
    }


type alias AuthenticationResult =
    Result AuthenticationError LoggedInUser



-- Lock 11


type alias LockParameters =
    ( String, String, LockOptions )


type alias LockAuthenticationParameters =
    { redirect : Bool
    , responseType : String
    , params :
        { scope : String }
    }


type alias LockOptions =
    { allowedConnections : List String
    , audience : String
    , auth : LockAuthenticationParameters
    , autoclose : Bool
    , disableSignupAction : Bool
    , languageDictionary : { title : String }
    , oidcConformant : Bool
    , rememberLastLogin : Bool
    , theme :
        { logo : String
        , primaryColor : String
        }
    }
