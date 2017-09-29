module Main exposing (..)

import Html exposing (..)
import View exposing (..)
import Model exposing (..)
import Update exposing (..)


initialVotes : List UserVote
initialVotes =
    [ { user = "brian"
      , pokemonNr = 1
      , rating = 2
      }
    , { user = "ruitje"
      , pokemonNr = 1
      , rating = 3
      }
    , { user = "brian"
      , pokemonNr = 151
      , rating = 2
      }
    ]


initialData : Pokedex
initialData =
    { pokemon =
        [ { generation = 3
          , url = "https://bulbapedia.bulbagarden.net/wiki/Absol_(Pok%C3%A9mon)"
          , image = "https://omg.pokemondb.net/artwork/absol.jpg"
          , name = "Absol"
          , number = 359
          }
        , { generation = 3
          , url = "https://bulbapedia.bulbagarden.net/wiki/Aggron_(Pok%C3%A9mon)"
          , image = "https://omg.pokemondb.net/artwork/aggron.jpg"
          , name = "Aggron"
          , number = 306
          }
        ]
    , cachedGenerations = [ 3 ]
    }


initialState : ApplicationState
initialState =
    { user = Nothing
    , loggedIn = False
    , generation = 3
    , letter = 'A'
    , votes = initialVotes
    }


main =
    Html.beginnerProgram
        { model = initialState
        , view = view
        , update = update
        }



-- main = viewPokemonTable initialState initialData
