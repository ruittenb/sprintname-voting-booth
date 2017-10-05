module CommandsPokemon exposing (loadPokemon)

import Http exposing (get)
import RemoteData exposing (WebData, sendRequest)
import Json.Decode as Decode exposing (Decoder, decodeValue)
import Json.Decode.Pipeline exposing (decode, required, optional, resolve)
import Constants exposing (..)
import Models exposing (..)
import Helpers exposing (capitalized)
import Msgs exposing (Msg)
import Numeral exposing (format)


loadPokemon : Int -> Cmd Msg
loadPokemon num =
    let
        pokemonNumApiUrl =
            pokemonApiUrl ++ toString num
    in
        Http.get pokemonNumApiUrl (decodePokemon num)
            |> RemoteData.sendRequest
            |> Cmd.map ((,) num)
            |> Cmd.map Msgs.OnLoadPokemon


decodePokemon : Int -> Decoder Pokemon
decodePokemon num =
    let
        imageUrl =
            case num of
                0 ->
                    missingNoImgUrl

                _ ->
                    pokemonImageBaseUrl ++ format "000" (toFloat num) ++ ".png"

        toDecoder id name =
            let
                capName =
                    capitalized name

                pokemonWikiUrl =
                    wikiUrl capName
            in
                Decode.succeed (Pokemon id capName imageUrl pokemonWikiUrl)
    in
        decode toDecoder
            |> required "id" Decode.int
            |> required "name" Decode.string
            |> resolve
