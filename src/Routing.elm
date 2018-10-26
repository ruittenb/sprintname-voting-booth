module Routing
    exposing
        ( parseLocation
        , createBrowsePath
        , createSearchPath
        , createShowRankingsPath
        , createShowVotesPath
        )

import Char
import Navigation exposing (Location)
import UrlParser exposing (Parser, (</>), parseHash, custom, s, string)
import Models.Types exposing (Route(..), Subpage)


searchPathSegment : String
searchPathSegment =
    "search"


browsePathSegment : String
browsePathSegment =
    "browse"


showVotesPathSegment : String
showVotesPathSegment =
    "show-votes"


showRankingsPathSegment : String
showRankingsPathSegment =
    "show-rankings"


createSearchPath : String -> String
createSearchPath query =
    "#/" ++ searchPathSegment ++ "/" ++ query


createBrowsePath : Int -> Char -> String
createBrowsePath gen letter =
    "#/" ++ browsePathSegment ++ "/" ++ (toString gen) ++ (String.fromChar letter)


createShowRankingsPath : Int -> Char -> String
createShowRankingsPath gen letter =
    (createBrowsePath gen letter) ++ "/" ++ showRankingsPathSegment


createShowVotesPath : Int -> Char -> String
createShowVotesPath gen letter =
    (createBrowsePath gen letter) ++ "/" ++ showVotesPathSegment


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
        [ UrlParser.map BrowseWithPeopleVotes (s browsePathSegment </> subPageParser </> s showVotesPathSegment)
        , UrlParser.map BrowseWithPokemonRankings (s browsePathSegment </> subPageParser </> s showRankingsPathSegment)
        , UrlParser.map Browse (s browsePathSegment </> subPageParser)
        , UrlParser.map Search (s searchPathSegment </> string)
        ]


parseLocation : Location -> Maybe Route
parseLocation location =
    parseHash routeParser location
