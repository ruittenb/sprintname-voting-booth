module Models exposing (..)


type StatusLevel
    = Error
    | Notice


type alias LighthouseData =
    { name : String
    , caption : String
    }


type alias UserVote =
    { pokemonNumber : Int
    , vote : Int
    }


type alias CurrentUserName =
    Maybe String


type alias ApplicationState =
    { user : CurrentUserName
    , loggedIn : Bool
    , statusMessage : String
    , statusLevel : StatusLevel
    , generation : Int
    , letter : Char
    , pokedex : Pokedex
    , ratings : List UserRatings
    }


type alias UserRating =
    { userName : String
    , color : String
    , rating : Int
    }


type alias UserRatings =
    { userName : String
    , color : String
    , ratings : String
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

    --, image = "https://cdn.bulbagarden.net/upload/9/98/Missingno_RB.png"
    , image = "https://wiki.p-insurgence.com/images/0/09/722.png"
    , url = "https://bulbapedia.bulbagarden.net/wiki/MissingNo."
    }


initialRatings : List UserRatings
initialRatings =
    [ { userName = "Andrew"
      , color = "purple"
      , ratings = "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"
      }
    , { userName = "Brian"
      , color = "#69a1b3"
      , ratings = "02000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"
      }
    , { userName = "Patrick"
      , color = "#bd8f39"
      , ratings = "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"
      }
    , { userName = "René"
      , color = "#619c61"
      , ratings = "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"
      }
    ]


initialPokedex : Pokedex
initialPokedex =
    [ { generation = 0
      , pokemon = [ missingNo ]
      }
    , { generation = 1
      , pokemon =
            [ { url = "https://bulbapedia.bulbagarden.net/wiki/Alakazam_(Pok%C3%A9mon)"
              , image = "https://img.pokemondb.net/artwork/alakazam.jpg"
              , name = "Alakazam"
              , number = 65
              }
            , { url = "https://bulbapedia.bulbagarden.net/wiki/Aerodactyl_(Pok%C3%A9mon)"
              , image = "https://img.pokemondb.net/artwork/aerodactyl.jpg"
              , name = "Aerodactyl"
              , number = 142
              }
            , { url = "https://bulbapedia.bulbagarden.net/wiki/Articuno_(Pok%C3%A9mon)"
              , image = "https://img.pokemondb.net/artwork/articuno.jpg"
              , name = "Articuno"
              , number = 144
              }
            , { url = "https://bulbapedia.bulbagarden.net/wiki/Blastoise_(Pok%C3%A9mon)"
              , image = "https://img.pokemondb.net/artwork/blastoise.jpg"
              , name = "Blastoise"
              , number = 9
              }
            , { url = "https://bulbapedia.bulbagarden.net/wiki/Bulbasaur_(Pok%C3%A9mon)"
              , image = "https://img.pokemondb.net/artwork/bulbasaur.jpg"
              , name = "Bulbasaur"
              , number = 1
              }
            , { url = "https://bulbapedia.bulbagarden.net/wiki/Squirtle_(Pok%C3%A9mon)"
              , image = "https://img.pokemondb.net/artwork/squirtle.jpg"
              , name = "Squirtle"
              , number = 7
              }
            , { url = "https://bulbapedia.bulbagarden.net/wiki/Snorlax_(Pok%C3%A9mon)"
              , image = "https://img.pokemondb.net/artwork/snorlax.jpg"
              , name = "Snorlax"
              , number = 143
              }
            ]
      }
    , { generation = 2
      , pokemon = []
      }
    , { generation = 3
      , pokemon =
            [ { url = "https://bulbapedia.bulbagarden.net/wiki/Absol_(Pok%C3%A9mon)"
              , image = "https://img.pokemondb.net/artwork/absol.jpg"
              , name = "Absol"
              , number = 359
              }
            , { url = "https://bulbapedia.bulbagarden.net/wiki/Aggron_(Pok%C3%A9mon)"
              , image = "https://img.pokemondb.net/artwork/aggron.jpg"
              , name = "Aggron"
              , number = 306
              }
            , { url = "https://bulbapedia.bulbagarden.net/wiki/Blaziken_(Pok%C3%A9mon)"
              , image = "https://img.pokemondb.net/artwork/blaziken.jpg"
              , name = "Blaziken"
              , number = 257
              }
            ]
      }
    ]


initialState : ApplicationState
initialState =
    { user = Just "René"
    , loggedIn = False
    , statusMessage = ""
    , statusLevel = Notice
    , generation = 1
    , letter = 'S'
    , pokedex = initialPokedex
    , ratings = initialRatings
    }
