module Commands.Pokemon exposing (decodePokedex)

import RemoteData exposing (fromResult)
import Json.Encode as Encode exposing (Value)
import Json.Decode as Decode exposing (Decoder, decodeValue)
import Json.Decode.Pipeline exposing (decode, required, optional, resolve)
import Models.Pokemon exposing (..)


decodePokedex : Value -> RemotePokedex
decodePokedex val =
    decodeValue (Decode.list pokemonDecoder) val
        |> RemoteData.fromResult


pokemonDecoder : Decoder Pokemon
pokemonDecoder =
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
            |> required "variants" pokemonVariantsDecoder
            |> resolve


pokemonVariantsDecoder : Decoder (List PokemonVariant)
pokemonVariantsDecoder =
    Decode.list pokemonVariantDecoder


pokemonVariantDecoder : Decoder PokemonVariant
pokemonVariantDecoder =
    decode PokemonVariant
        |> required "image" Decode.string
        |> required "vname" Decode.string
