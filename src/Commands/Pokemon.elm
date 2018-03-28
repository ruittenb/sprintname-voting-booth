module Commands.Pokemon exposing (decodePokedex)

import Http exposing (get)
import RemoteData exposing (RemoteData, WebData, sendRequest, fromResult)
import Json.Encode exposing (Value)
import Json.Decode as Decode exposing (Decoder, decodeValue)
import Json.Decode.Pipeline exposing (decode, required, optional, resolve)
import Models.Pokedex exposing (..)


--import Constants exposing (..)
--import Msgs exposing (Msg)
--loadPokedex : Cmd Msg
--loadPokedex =
--    Http.get pokedexApiUrl decodePokedex
--        |> RemoteData.sendRequest
--        |> Cmd.map Msgs.OnLoadPokedex


decodePokedex : Value -> WebData (List Pokemon)
decodePokedex val =
    decodeValue (Decode.list decodePokemon) val
        -- Result String a
        |> RemoteData.fromResult



-- RemoteData String a
--        |> RemoteData.mapError (\_ -> )             -- RemoteData Http.Error a (=== WebData a)


decodePokemon : Decoder Pokemon
decodePokemon =
    let
        toDecoder id number generation letterString name url variants =
            let
                currentVariant =
                    1

                letterChar =
                    String.uncons letterString
                        |> Maybe.map Tuple.first
                        |> Maybe.withDefault '?'
            in
                Decode.succeed (Pokemon id number generation letterChar name url currentVariant variants)
    in
        decode toDecoder
            |> required "id" Decode.int
            |> required "number" Decode.int
            |> required "generation" Decode.int
            |> required "letter" Decode.string
            |> required "name" Decode.string
            |> required "url" Decode.string
            |> required "variants" decodePokemonVariants
            |> resolve


decodePokemonVariants : Decoder (List PokemonVariant)
decodePokemonVariants =
    Decode.list decodePokemonVariant


decodePokemonVariant : Decoder PokemonVariant
decodePokemonVariant =
    decode PokemonVariant
        |> required "image" Decode.string
        |> required "vname" Decode.string
