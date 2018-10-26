module Routing exposing (parseLocation)

import Char
import Navigation exposing (Location)
import UrlParser exposing (Parser, (</>), parseHash, custom, s, string)
import Models.Types exposing (Route(..), Subpage)
import Constants exposing (browsePathSegment, searchPathSegment)


extractSubpage : String -> Maybe Subpage
extractSubpage pathSegment =
    Maybe.map
        (\( gen, letter ) ->
            { generation = Char.toCode gen - 48
            , letter =
                String.toUpper letter
                    |> String.toList
                    |> List.head
                    |> Maybe.withDefault '_'
            }
        )
        (String.uncons pathSegment)


subPageParser : Parser (Subpage -> a) a
subPageParser =
    custom "SUBPAGE" <|
        \pathSegment ->
            case extractSubpage pathSegment of
                Nothing ->
                    Err "Cannot parse path segment"

                Just subPage ->
                    Ok subPage


routeParser : Parser (Route -> a) a
routeParser =
    UrlParser.oneOf
        [ UrlParser.map BrowseWithPeopleVotes (s browsePathSegment </> subPageParser </> s "show-votes")
        , UrlParser.map BrowseWithPokemonRankings (s browsePathSegment </> subPageParser </> s "show-rankings")
        , UrlParser.map Browse (s browsePathSegment </> subPageParser)
        , UrlParser.map Search (s searchPathSegment </> string)
        ]


parseLocation : Location -> Maybe Route
parseLocation location =
    parseHash routeParser location
