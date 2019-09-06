module Commands.Pages exposing (decodePages)

import RemoteData exposing (fromResult)
import Json.Encode as Encode exposing (Value)
import Json.Decode as Decode exposing (Decoder, decodeValue, int, string, bool, nullable)
import Json.Decode.Pipeline exposing (decode, required, optional, resolve)
import Models.Pages exposing (..)


decodePages : Value -> RemotePages
decodePages val =
    decodeValue (Decode.list pageDecoder) val
        |> RemoteData.fromResult


pageDecoder : Decoder Page
pageDecoder =
    let
        toDecoder generation letter open winnerNum winnerName startDate =
            let
                ( letterChar, _ ) =
                    String.uncons letter
                        |> Maybe.withDefault ( '?', "" )
            in
                Decode.succeed (Page generation letterChar open winnerNum winnerName startDate)
    in
        decode toDecoder
            |> required "generation" int
            |> required "letter" string
            |> required "open" bool
            |> optional "winnerNum" (nullable int) Nothing
            |> optional "winnerName" (nullable string) Nothing
            |> optional "startDate" (nullable string) Nothing
            |> resolve
