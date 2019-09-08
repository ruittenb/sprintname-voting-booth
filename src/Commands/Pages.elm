module Commands.Pages exposing (savePageLockState, decodePages, decodePage)

import RemoteData exposing (fromResult)
import Json.Encode as Encode exposing (Value)
import Json.Decode as Decode exposing (Decoder, decodeValue, int, string, bool, nullable)
import Json.Decode.Pipeline exposing (decode, required, optional, resolve)
import Models.Pages exposing (..)
import Ports exposing (savePage)

savePageLockState : Page -> Cmd msg
savePageLockState page =
    let
        -- ports don't support Char types
        portCompatiblePage =
            { page | letter = String.fromChar page.letter }
    in
        savePage portCompatiblePage


decodePages : Value -> RemotePages
decodePages val =
    decodeValue (Decode.list pageDecoder) val
        |> RemoteData.fromResult


decodePage : Value -> RemotePage
decodePage val =
    decodeValue pageDecoder val
        |> RemoteData.fromResult


pageDecoder : Decoder Page
pageDecoder =
    let
        toDecoder id generation letter open winnerNum winnerName startDate =
            let
                ( letterChar, _ ) =
                    String.uncons letter
                        |> Maybe.withDefault ( '?', "" )
            in
                Decode.succeed (Page id generation letterChar open winnerNum winnerName startDate)
    in
        decode toDecoder
            |> required "id" int
            |> required "generation" int
            |> required "letter" string
            |> required "open" bool
            |> optional "winnerNum" (nullable int) Nothing
            |> optional "winnerName" (nullable string) Nothing
            |> optional "startDate" (nullable string) Nothing
            |> resolve
