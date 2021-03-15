module Commands.Pages exposing (decodePage, decodePages, savePageState)

import Json.Decode as Decode exposing (Decoder, bool, decodeValue, int, nullable, string)
import Json.Decode.Pipeline exposing (decode, optional, required, resolve)
import Json.Encode as Encode exposing (Value)
import Models.Pages exposing (..)
import Ports exposing (savePage)
import RemoteData exposing (fromResult)


savePageState : Page -> Cmd msg
savePageState page =
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
        toDecoder id generation letter open winnerId winnerName startDate =
            let
                ( letterChar, _ ) =
                    String.uncons letter
                        |> Maybe.withDefault ( '?', "" )
            in
            Decode.succeed (Page id generation letterChar open winnerId winnerName startDate)
    in
    decode toDecoder
        |> required "id" int
        |> required "generation" string
        |> required "letter" string
        |> required "open" bool
        |> optional "winnerId" (nullable int) Nothing
        |> optional "winnerName" (nullable string) Nothing
        |> optional "startDate" (nullable string) Nothing
        |> resolve
