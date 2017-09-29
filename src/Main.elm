module Main exposing (..)

import View exposing (..)
import Model exposing (..)


initialData : Pokedex
initialData =
    { pokemon =
        [ { generation = 3
          , url = "https://bulbapedia.bulbagarden.net/wiki/Absol_(Pok%C3%A9mon)"
          , image = "https://img.pokemondb.net/artwork/absol.jpg"
          , name = "Absol"
          , number = 359
          , votes =
                [ { user = "brian"
                  , rating = 2
                  }
                ]
          }
        , { generation = 3
          , url = "https://bulbapedia.bulbagarden.net/wiki/Aggron_(Pok%C3%A9mon)"
          , image = "https://img.pokemondb.net/artwork/aggron.jpg"
          , name = "Aggron"
          , number = 306
          , votes =
                [ { user = "ruitje"
                  , rating = 3
                  }
                , { user = "brian"
                  , rating = 2
                  }
                ]
          }
        ]
    }


initialState : ApplicationState
initialState =
    { user = Nothing
    , loggedIn = False
    , generation = 3
    , letter = 'A'
    }


main =
    viewPokemonTable initialState initialData
