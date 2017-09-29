module Models exposing (..)

import Array exposing (..)


type alias LighthouseData =
    { name : String
    , title : String
    }


type alias UserVote =
    { pokemonNr : Int
    , rating : Int
    }


type alias ApplicationState =
    { user : Maybe String
    , loggedIn : Bool
    , generation : Int
    , letter : Char
    , pokedex : Pokedex
    , votes : List UserRatings
    }


type alias UserRatings =
    { userName : String
    , ratings : Array Int
    }


type alias Pokemon =
    { number : Int
    , name : String
    , image : String
    , url : String
    }


type alias PokeGeneration =
    { generation : Int
    , pokemon : List Pokemon
    }


type alias Pokedex =
    List PokeGeneration


missingNo : Pokemon
missingNo =
    { number = 0
    , name = "MissingNo."
    , image = "https://cdn.bulbagarden.net/upload/9/98/Missingno_RB.png"
    , url = "https://bulbapedia.bulbagarden.net/wiki/MissingNo."
    }


initialVotes : List UserRatings
initialVotes =
    [ { userName = "Andrew"
      , ratings = Array.fromList []
      }
    , { userName = "Brian"
      , ratings = Array.fromList []
      }
    , { userName = "Patrick"
      , ratings = Array.fromList []
      }
    , { userName = "René"
      , ratings = Array.fromList []
      }
    ]


initialPokedex : Pokedex
initialPokedex =
    [ { generation = 0
      , pokemon = [ missingNo ]
      }
    , { generation = 1
      , pokemon = []
      }
    , { generation = 2
      , pokemon = []
      }
    , { generation = 3
      , pokemon =
            [ { url = "https://bulbapedia.bulbagarden.net/wiki/Absol_(Pok%C3%A9mon)"
              , image = "https://omg.pokemondb.net/artwork/absol.jpg"
              , name = "Absol"
              , number = 359
              }
            , { url = "https://bulbapedia.bulbagarden.net/wiki/Aggron_(Pok%C3%A9mon)"
              , image = "https://omg.pokemondb.net/artwork/aggron.jpg"
              , name = "Aggron"
              , number = 306
              }
            , { url = "https://bulbapedia.bulbagarden.net/wiki/Blaziken_(Pok%C3%A9mon)"
              , image = "https://omg.pokemondb.net/artwork/blaziken.jpg"
              , name = "Blaziken"
              , number = 257
              }
            ]
      }
    ]


initialState : ApplicationState
initialState =
    { user = Nothing
    , loggedIn = False
    , generation = 3
    , letter = 'C'
    , pokedex = initialPokedex
    , votes = initialVotes
    }
