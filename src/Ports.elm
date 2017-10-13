port module Ports exposing (preloadImages, auth0showLock, auth0authResult, auth0logout)

import Auth0


port preloadImages : List { generation : Int, imageUrl : String } -> Cmd msg


port auth0showLock : Auth0.Options -> Cmd msg


port auth0authResult : (Auth0.RawAuthenticationResult -> msg) -> Sub msg


port auth0logout : () -> Cmd msg
