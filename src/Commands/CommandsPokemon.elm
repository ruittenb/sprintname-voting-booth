module CommandsPokemon exposing (loadPokemon, loadGeneration)

import Http exposing (get)
import RemoteData exposing (WebData, sendRequest)
import Json.Decode as Decode exposing (Decoder, decodeValue)
import Json.Decode.Pipeline exposing (decode, required, optional, resolve)
import Constants exposing (..)
import Models exposing (..)
import Helpers exposing (capitalized, generationRange)
import Msgs exposing (Msg)
import Numeral exposing (format)


loadGeneration : Int -> Cmd Msg
loadGeneration gen =
    Cmd.none



{-
      let
          numberRange =
              generationRange gen
      in
          List.map (
              loadOnePokemon
              ) numberRange


   RemoteData.andThen



-}
{-
   loadTwoPokemon : Int -> Cmd ( Int, WebData Pokemon )
   loadTwoPokemon =
       List.map
       -- returns a Cmd (WebData Pokemon)
       (\num ->
       let
           pokemonNumApiUrl =
               pokemonApiUrl ++ toString num
       in
           Http.get pokemonNumApiUrl (decodePokemon num)
               |> RemoteData.sendRequest
       )
       List.range 25 26




               |> Cmd.map ((,) num)
       RemoteData.andThen

-}


loadPokemon : Int -> Cmd Msg
loadPokemon num =
    -- Int -> Cmd (Msgs.OnLoadPokemon (num (WebData Pokemon)))
    loadOnePokemon num
        |> Cmd.map Msgs.OnLoadPokemon


loadOnePokemon : Int -> Cmd ( Int, WebData Pokemon )
loadOnePokemon num =
    let
        pokemonNumApiUrl =
            pokemonApiUrl ++ toString num
    in
        Http.get pokemonNumApiUrl (decodePokemon num)
            |> RemoteData.sendRequest
            |> Cmd.map ((,) num)


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
