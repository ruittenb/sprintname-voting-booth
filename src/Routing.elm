module Routing
    exposing
        ( parseLocation
        , createBrowsePath
        , createSearchPath
        , createShowRankingsPath
        , createShowVotersPath
        )

import Char
import Navigation exposing (Location)
import UrlParser exposing (Parser, (</>), parseHash, custom, s, string)
import Models.Types exposing (Route(..), Mask(..), Subpage)


searchPathSegment : String
searchPathSegment =
    "search"


browsePathSegment : String
browsePathSegment =
    "browse"


showVotersPathSegment : String
showVotersPathSegment =
    "show-voters"


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


createShowVotersPath : Int -> Char -> String
createShowVotersPath gen letter =
    (createBrowsePath gen letter) ++ "/" ++ showVotersPathSegment


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
        [ UrlParser.map (Browse WithPeopleVotes) (s browsePathSegment </> subPageParser </> s showVotersPathSegment)
        , UrlParser.map (Browse WithPokemonRankings) (s browsePathSegment </> subPageParser </> s showRankingsPathSegment)
        , UrlParser.map (Browse WithoutMask) (s browsePathSegment </> subPageParser)
        , UrlParser.map Search (s searchPathSegment </> string)
        ]


parseLocation : Location -> Maybe Route
parseLocation location =
    parseHash routeParser location
