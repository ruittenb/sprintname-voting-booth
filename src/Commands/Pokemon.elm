module Commands.Pokemon exposing (loadPokedex)

import Http exposing (get)
import RemoteData exposing (WebData, sendRequest)
import Json.Decode as Decode exposing (Decoder, decodeValue)
import Json.Decode.Pipeline exposing (decode, required, optional, resolve)
import Constants exposing (..)
import Models.Pokedex exposing (..)
import Msgs exposing (Msg)


loadPokedex : Cmd Msg
loadPokedex =
    Http.get pokedexApiUrl decodePokedex
        |> RemoteData.sendRequest
        |> Cmd.map Msgs.OnLoadPokedex


decodePokedex : Decoder (List Pokemon)
decodePokedex =
    Decode.list decodePokemon


decodePokemon : Decoder Pokemon
decodePokemon =
    let
        toDecoder id number generation letterString name url variants =
            let
                currentVariant =
                    1

                letterChar =
                    case String.uncons letterString of
                        Just ( first, _ ) ->
                            first

                        _ ->
                            '?'
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
