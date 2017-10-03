module Models exposing (..)

import RemoteData exposing (WebData)


type StatusLevel
    = Error
    | Notice
    | None


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


type alias TeamRating =
    List UserRating


type alias TeamRatings =
    List UserRatings


type alias ApplicationState =
    { user : CurrentUserName
    , statusMessage : String
    , statusLevel : StatusLevel
    , generation : Int
    , letter : Char
    , cachedGenerations : List Int
    , pokedex : Pokedex
    , ratings : WebData TeamRatings
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
    , image = ""
    , url = "https://bulbapedia.bulbagarden.net/wiki/MissingNo."
    }


missingNoImgUrl : String
missingNoImgUrl =
    "https://wiki.p-insurgence.com/images/0/09/722.png"


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
            , { url = "https://bulbapedia.bulbagarden.net/wiki/Banette_(Pok%C3%A9mon)"
              , image = "https://img.pokemondb.net/artwork/banette.jpg"
              , name = "Banette"
              , number = 354
              }
            , { url = "https://bulbapedia.bulbagarden.net/wiki/Breloom_(Pok%C3%A9mon)"
              , image = "https://img.pokemondb.net/artwork/breloom.jpg"
              , name = "Breloom"
              , number = 286
              }
            , { url = "https://bulbapedia.bulbagarden.net/wiki/Beldum_(Pok%C3%A9mon)"
              , image = "https://img.pokemondb.net/artwork/beldum.jpg"
              , name = "Beldum"
              , number = 374
              }
            , { url = "https://bulbapedia.bulbagarden.net/wiki/Baltoy_(Pok%C3%A9mon)"
              , image = "https://img.pokemondb.net/artwork/baltoy.jpg"
              , name = "Baltoy"
              , number = 343
              }
            , { url = "https://bulbapedia.bulbagarden.net/wiki/Bagon_(Pok%C3%A9mon)"
              , image = "https://img.pokemondb.net/artwork/bagon.jpg"
              , name = "Bagon"
              , number = 371
              }
            , { url = "https://bulbapedia.bulbagarden.net/wiki/Cacnea_(Pok%C3%A9mon)"
              , image = "https://img.pokemondb.net/artwork/cacnea.jpg"
              , name = "Cacnea"
              , number = 331
              }
            , { url = "https://bulbapedia.bulbagarden.net/wiki/Cacturne_(Pok%C3%A9mon)"
              , image = "https://img.pokemondb.net/artwork/cacturne.jpg"
              , name = "Cacturne"
              , number = 332
              }
            , { url = "https://bulbapedia.bulbagarden.net/wiki/Camerupt_(Pok%C3%A9mon)"
              , image = "https://img.pokemondb.net/artwork/camerupt.jpg"
              , name = "Camerupt"
              , number = 323
              }
            , { url = "https://bulbapedia.bulbagarden.net/wiki/Carvanha_(Pok%C3%A9mon)"
              , image = "https://img.pokemondb.net/artwork/carvanha.jpg"
              , name = "Carvanha"
              , number = 318
              }
            , { url = "https://bulbapedia.bulbagarden.net/wiki/Cascoon_(Pok%C3%A9mon)"
              , image = "https://img.pokemondb.net/artwork/cascoon.jpg"
              , name = "Cascoon"
              , number = 268
              }
            , { url = "https://bulbapedia.bulbagarden.net/wiki/Castform_(Pok%C3%A9mon)"
              , image = "https://img.pokemondb.net/artwork/castform.jpg"
              , name = "Castform"
              , number = 351
              }
            , { url = "https://bulbapedia.bulbagarden.net/wiki/Chimecho_(Pok%C3%A9mon)"
              , image = "https://img.pokemondb.net/artwork/chimecho.jpg"
              , name = "Chimecho"
              , number = 358
              }
            , { url = "https://bulbapedia.bulbagarden.net/wiki/Clamperl_(Pok%C3%A9mon)"
              , image = "https://img.pokemondb.net/artwork/clamperl.jpg"
              , name = "Clamperl"
              , number = 366
              }
            , { url = "https://bulbapedia.bulbagarden.net/wiki/Claydol_(Pok%C3%A9mon)"
              , image = "https://img.pokemondb.net/artwork/claydol.jpg"
              , name = "Claydol"
              , number = 344
              }
            , { url = "https://bulbapedia.bulbagarden.net/wiki/Combusken_(Pok%C3%A9mon)"
              , image = "https://img.pokemondb.net/artwork/combusken.jpg"
              , name = "Combusken"
              , number = 256
              }
            , { url = "https://bulbapedia.bulbagarden.net/wiki/Corphish_(Pok%C3%A9mon)"
              , image = "https://img.pokemondb.net/artwork/corphish.jpg"
              , name = "Corphish"
              , number = 341
              }
            , { url = "https://bulbapedia.bulbagarden.net/wiki/Cradily_(Pok%C3%A9mon)"
              , image = "https://img.pokemondb.net/artwork/cradily.jpg"
              , name = "Cradily"
              , number = 346
              }
            , { url = "https://bulbapedia.bulbagarden.net/wiki/Crawdaunt_(Pok%C3%A9mon)"
              , image = "https://img.pokemondb.net/artwork/crawdaunt.jpg"
              , name = "Crawdaunt"
              , number = 342
              }
            , { url = "https://bulbapedia.bulbagarden.net/wiki/Delcatty_(Pok%C3%A9mon)"
              , image = "https://img.pokemondb.net/artwork/delcatty.jpg"
              , name = "Delcatty"
              , number = 301
              }
            , { url = "https://bulbapedia.bulbagarden.net/wiki/Deoxys_(Pok%C3%A9mon)"
              , image = "https://img.pokemondb.net/artwork/deoxys-normal.jpg"
              , name = "Deoxys"
              , number = 386
              }
            , { url = "https://bulbapedia.bulbagarden.net/wiki/Dusclops_(Pok%C3%A9mon)"
              , image = "https://img.pokemondb.net/artwork/dusclops.jpg"
              , name = "Dusclops"
              , number = 356
              }
            , { url = "https://bulbapedia.bulbagarden.net/wiki/Duskull_(Pok%C3%A9mon)"
              , image = "https://img.pokemondb.net/artwork/duskull.jpg"
              , name = "Duskull"
              , number = 355
              }
            , { url = "https://bulbapedia.bulbagarden.net/wiki/Dustox_(Pok%C3%A9mon)"
              , image = "https://img.pokemondb.net/artwork/dustox.jpg"
              , name = "Dustox"
              , number = 269
              }
            ]
      }
    ]


initialState : ApplicationState
initialState =
    { user = Just "René"
    , statusMessage = ""
    , statusLevel = None
    , generation = 3
    , letter = 'B'
    , cachedGenerations = [ 0 ]
    , pokedex = initialPokedex
    , ratings = RemoteData.NotAsked
    }
