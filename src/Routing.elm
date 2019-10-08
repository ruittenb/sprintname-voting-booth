module Routing
    exposing
        ( parseLocation
        , createDefaultPath
        , createBrowsePath
        , createSearchPath
        , createShowRankingsPath
        , createShowVotersPath
        )

import Char
import Navigation exposing (Location)
import UrlParser exposing (Parser, (</>), parseHash, custom, s, string)
import Models.Types exposing (Route(..), BrowseMode(..), SubPage)


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


createDefaultPath : String
createDefaultPath =
    "#/"


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


unwrap : a -> (SubPage -> a) -> Route -> a
unwrap defaultValue mapFunction route =
    case route of
        Browse _ subPage ->
            mapFunction subPage

        _ ->
            defaultValue


extractSubpage : String -> Maybe SubPage
extractSubpage pathSegment =
    String.uncons pathSegment
        |> Maybe.map
            (\( gen, letter ) ->
                { generation = Char.toCode gen - 48
                , letter =
                    String.toUpper letter
                        |> String.toList
                        |> List.head
                        -- FIXME magical value
                        |> Maybe.withDefault '_'
                }
            )


subPageParser : Parser (SubPage -> a) a
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
        , UrlParser.map (Browse Free) (s browsePathSegment </> subPageParser)
        , UrlParser.map Search (s searchPathSegment </> string)
        ]


parseLocation : Location -> Route
parseLocation location =
    parseHash routeParser location
        |> Maybe.withDefault Default
