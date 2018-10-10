module Constants.Authentication exposing (lockParameters)

import Models.Auth exposing (LockParameters, LockOptions, LockAuthenticationParameters)


clientId : String
clientId =
    "n0dhDfP61nzDIRpMaw8UsoPLiNxcxdM9"


clientDomain : String
clientDomain =
    "proforto.eu.auth0.com"


authenticationParameters : LockAuthenticationParameters
authenticationParameters =
    -- learn more about authentication parameters at:
    -- https://auth0.com/docs/libraries/lock/v11/sending-authentication-parameters
    { redirect = False
    , responseType = "token id_token"
    , params =
        -- Learn more about scopes at: https://auth0.com/docs/scopes
        { scope = "openid email profile"
        }
    }


lockOptions : LockOptions
lockOptions =
    { allowedConnections = [ "google-oauth2" ]
    , auth = authenticationParameters
    , audience = "proforto.eu.auth0.com/userinfo"
    , rememberLastLogin = True
    , disableSignupAction = True
    , oidcConformant = True
    , autoclose = True
    , languageDictionary =
        { title = "Voting Booth Login"
        }
    , theme =
        { logo = "/favicons/favicon-58x58.png"
        }
    }


lockParameters : LockParameters
lockParameters =
    ( clientId, clientDomain, lockOptions )
