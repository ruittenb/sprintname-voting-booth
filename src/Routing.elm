module Routing
    exposing
        ( parseLocation
        , createDefaultPath
        , createBrowsePath
        , createBrowseFreelyPath
        , createBrowseWithRankingsPath
        , createBrowseWithVotersPath
        , createBrowseWithCopyrightPath
        , createSearchPath
        , createSearchFreelyPath
        , createSearchWithCopyrightPath
        )

import Char
import Array
import Helpers exposing (andThen2)
import Navigation exposing (Location)
import UrlParser exposing (Parser, (</>), parseHash, custom, s, string)
import Constants exposing (allLetters, allGenerations, genLetterUrlSeparator)
import Models.Types exposing (Route(..), BrowseMode(..), SearchMode(..), SubPage)

defaultPathSegment : String
defaultPathSegment =
    "#/"

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


showCopyrightPathSegment : String
showCopyrightPathSegment =
    "show-copyright"


-- Default path

createDefaultPath : String
createDefaultPath =
    defaultPathSegment


-- Search paths

createSearchFreelyPath : String -> String
createSearchFreelyPath query =
    defaultPathSegment ++ searchPathSegment ++ "/" ++ query


createSearchWithCopyrightPath : String -> String
createSearchWithCopyrightPath query =
    (createSearchFreelyPath query) ++ "/" ++ showCopyrightPathSegment


createSearchPath : SearchMode -> String -> String
createSearchPath searchmode query =
    case searchmode of
        SWithCopyright ->
            createSearchWithCopyrightPath query

        SFreely ->
            createSearchFreelyPath query


-- Browse paths

createBrowseFreelyPath : String -> Char -> String
createBrowseFreelyPath gen letter =
    defaultPathSegment ++ browsePathSegment ++ "/" ++ gen ++ genLetterUrlSeparator ++ (String.fromChar letter)


createBrowseWithRankingsPath : String -> Char -> String
createBrowseWithRankingsPath gen letter =
    (createBrowseFreelyPath gen letter) ++ "/" ++ showRankingsPathSegment


createBrowseWithVotersPath : String -> Char -> String
createBrowseWithVotersPath gen letter =
    (createBrowseFreelyPath gen letter) ++ "/" ++ showVotersPathSegment


createBrowseWithCopyrightPath : String -> Char -> String
createBrowseWithCopyrightPath gen letter =
    (createBrowseFreelyPath gen letter) ++ "/" ++ showCopyrightPathSegment


createBrowsePath : BrowseMode -> String -> Char -> String
createBrowsePath browsemode gen letter =
    case browsemode of
        BWithPeopleVotes ->
            createBrowseWithVotersPath gen letter

        BWithPokemonRankings ->
            createBrowseWithRankingsPath gen letter

        BWithCopyright ->
            createBrowseWithCopyrightPath gen letter

        BFreely ->
            createBrowseFreelyPath gen letter


unwrap : a -> (SubPage -> a) -> Route -> a
unwrap defaultValue mapFunction route =
    case route of
        Browse _ subPage ->
            mapFunction subPage

        _ ->
            defaultValue

composeValidSubPage : String -> String -> Maybe SubPage
composeValidSubPage generation rawLetter =
    rawLetter
        |> String.toUpper
        |> String.toList
        |> List.head
        |> Maybe.andThen
            (\letter ->
                if
                    List.member letter allLetters
                    && List.member generation allGenerations
                then
                    Just
                        { generation = generation
                        , letter = letter
                        }
                else
                    Nothing
            )

extractSubpage : String -> Maybe SubPage
extractSubpage pathSegment =
    String.split genLetterUrlSeparator pathSegment
        |> Array.fromList
        |> (\segments ->
            let
                generation = Array.get 0 segments
                letter = Array.get 1 segments
            in
                andThen2 composeValidSubPage generation letter
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
        [ UrlParser.map (Browse BWithPeopleVotes) (s browsePathSegment </> subPageParser </> s showVotersPathSegment)
        , UrlParser.map (Browse BWithPokemonRankings) (s browsePathSegment </> subPageParser </> s showRankingsPathSegment)
        , UrlParser.map (Browse BWithCopyright) (s browsePathSegment </> subPageParser </> s showCopyrightPathSegment)
        , UrlParser.map (Browse BFreely) (s browsePathSegment </> subPageParser)
        , UrlParser.map (Search SWithCopyright) (s searchPathSegment </> string </> s showCopyrightPathSegment)
        , UrlParser.map (Search SFreely) (s searchPathSegment </> string)
        ]


parseLocation : Location -> Route
parseLocation location =
    parseHash routeParser location
        |> Maybe.withDefault Default
