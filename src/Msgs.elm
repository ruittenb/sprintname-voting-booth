module Msgs exposing (..)

--import Http
--import Material
--import RemoteData exposing (WebData)

import Model exposing (..)


type Msg
    = VoteForPokemon Pokemon
    | ChangeGeneration Int
    | ChangeLetter Char



{-
   | IncrementItemInCart LineItem
   | DecrementItemInCart LineItem
   | OnFetchCart (WebData Cart)
   | OnSaveCart (Result Http.Error Cart)
   | Mdl (Material.Msg Msg)
-}
