module Routing
    exposing
        ( parseLocation
        , createDefaultPath
        , createSearchPath
        , createBrowseModePath
        , createBrowsePath
        , createShowRankingsPath
        , createShowVotersPath
        , createShowCopyrightPath
        )

import Char
import Array
import Helpers exposing (andThen2)
import Navigation exposing (Location)
import UrlParser exposing (Parser, (</>), parseHash, custom, s, string)
import Constants exposing (allLetters, allGenerations, genLetterUrlSeparator)
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


showCopyrightPathSegment : String
showCopyrightPathSegment =
    "show-copyright"

createDefaultPath : String
createDefaultPath =
    "#/"


createSearchPath : String -> String
createSearchPath query =
    "#/" ++ searchPathSegment ++ "/" ++ query


createBrowsePath : String -> Char -> String
createBrowsePath gen letter =
    "#/" ++ browsePathSegment ++ "/" ++ gen ++ genLetterUrlSeparator ++ (String.fromChar letter)


createShowRankingsPath : String -> Char -> String
createShowRankingsPath gen letter =
    (createBrowsePath gen letter) ++ "/" ++ showRankingsPathSegment


createShowVotersPath : String -> Char -> String
createShowVotersPath gen letter =
    (createBrowsePath gen letter) ++ "/" ++ showVotersPathSegment


createShowCopyrightPath : String -> Char -> String
createShowCopyrightPath gen letter =
    (createBrowsePath gen letter) ++ "/" ++ showCopyrightPathSegment


createBrowseModePath : BrowseMode -> String -> Char -> String
createBrowseModePath mode gen letter =
    case mode of
        Freely ->
            createBrowsePath gen letter

        WithPeopleVotes ->
            createShowVotersPath gen letter

        WithPokemonRankings ->
            createShowRankingsPath gen letter

        WithCopyright ->
            createShowCopyrightPath gen letter


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
        [ UrlParser.map (Browse WithPeopleVotes) (s browsePathSegment </> subPageParser </> s showVotersPathSegment)
        , UrlParser.map (Browse WithPokemonRankings) (s browsePathSegment </> subPageParser </> s showRankingsPathSegment)
        , UrlParser.map (Browse WithCopyright) (s browsePathSegment </> subPageParser </> s showCopyrightPathSegment)
        , UrlParser.map (Browse Freely) (s browsePathSegment </> subPageParser)
        , UrlParser.map Search (s searchPathSegment </> string)
        ]


parseLocation : Location -> Route
parseLocation location =
    parseHash routeParser location
        |> Maybe.withDefault Default
