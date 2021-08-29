module Commands.Pokemon exposing (decodePokedex)

import RemoteData exposing (fromResult)
import Json.Encode as Encode exposing (Value)
import Json.Decode as Decode exposing (Decoder, decodeValue, int, string, nullable)
import Json.Decode.Pipeline exposing (decode, required, optional, resolve)
import Models.Pokemon exposing (..)


decodePokedex : Value -> RemotePokedex
decodePokedex val =
    decodeValue (Decode.list pokemonDecoder) val
        |> RemoteData.fromResult


pokemonDecoder : Decoder Pokemon
pokemonDecoder =
    let
        toDecoder id number generation description letterString name url variants =
            let
                currentVariant =
                    1

                letterChar =
                    String.uncons letterString
                        |> Maybe.map Tuple.first
                        |> Maybe.withDefault '?'
            in
                Decode.succeed (Pokemon id number generation description letterChar name url currentVariant variants)
    in
        decode toDecoder
            |> required "id" int
            |> required "number" int
            |> required "generation" string
            |> required "description" string
            |> required "letter" string
            |> required "name" string
            |> required "url" string
            |> required "variants" pokemonVariantsDecoder
            |> resolve


pokemonVariantsDecoder : Decoder (List PokemonVariant)
pokemonVariantsDecoder =
    Decode.list pokemonVariantDecoder


pokemonVariantDecoder : Decoder PokemonVariant
pokemonVariantDecoder =
    decode PokemonVariant
        |> required "image" string
        |> required "vname" string
        |> optional "description" (nullable string) Nothing
