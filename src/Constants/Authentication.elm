module Constants.Authentication exposing (auth0Options)

import Models.Auth exposing (LockOptions, LockAuthenticationParameters)


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


auth0Options : LockOptions
auth0Options =
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
        { logo = "/dist/favicon-58x58.png"
        }
    }
