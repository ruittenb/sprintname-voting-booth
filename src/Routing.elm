module Routing exposing (..)

import Navigation exposing (Location)
import UrlParser exposing (Parser, (</>), s, string, parseHash)


-- new


type Route
    = Browse String
    | BrowseWithPeopleVotes String
    | BrowseWithPokemonRankings String
    | Search String


routeParser : Parser (Route -> a) a
routeParser =
    UrlParser.oneOf
        [ UrlParser.map BrowseWithPeopleVotes (s "browse" </> int </> s "show-votes")
        , UrlParser.map BrowseWithPokemonRankings (s "browse" </> int </> s "show-rankings")
        , UrlParser.map Browse (s "browse" </> int)
        , UrlParser.map Search (s "search" </> string)
        ]


parseLocation : Location -> Maybe Route
parseLocation location =
    parseHash routeParser location



-- old


dissectLocationHash : Location -> Subpage -> Subpage
dissectLocationHash location defaultSubpage =
    let
        ( _, hash ) =
            String.uncons location.hash
                |> Maybe.withDefault ( '#', "" )
    in
        case String.uncons hash of
            Just ( gen, letter ) ->
                { generation = Char.toCode gen - 48
                , letter =
                    String.toUpper letter
                        |> String.toList
                        |> List.head
                        |> Maybe.withDefault '_'
                }

            Nothing ->
                defaultSubpage


hashToMsg : Location -> Msg
hashToMsg location =
    let
        invalidPage =
            { generation = -1, letter = '_' }

        subpage =
            dissectLocationHash location invalidPage
    in
        Msgs.GenerationAndLetterChanged subpage.generation subpage.letter
