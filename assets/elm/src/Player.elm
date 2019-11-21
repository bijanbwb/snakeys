module Player exposing
    ( Direction(..)
    , Player
    , playerData
    )

-- IMPORTS

import Color exposing (Color)



-- TYPES


type Direction
    = North
    | East
    | South
    | West


type alias Player =
    { avatarUrl : String
    , color : Color
    , direction : Direction
    , height : Int
    , id : Int
    , name : String
    , score : Int
    , width : Int
    , x : Int
    , y : Int
    }



-- DATA


playerData : List Player
playerData =
    [ { avatarUrl = "https://ca.slack-edge.com/T02A50N5X-U03CTQU93-c88640d8b72a-512"
      , color = Color.Blue
      , direction = East
      , height = 10
      , id = 1
      , name = "Bijan"
      , score = 0
      , width = 10
      , x = 100
      , y = 100
      }
    , { avatarUrl = "https://ca.slack-edge.com/T02A50N5X-UENQJLJTS-83d6e8679c9d-512"
      , color = Color.Red
      , direction = East
      , height = 10
      , id = 2
      , name = "Nick"
      , score = 0
      , width = 10
      , x = 100
      , y = 200
      }
    , { avatarUrl = "https://ca.slack-edge.com/T02A50N5X-UEBNS4XTL-1f772791e268-512"
      , color = Color.Green
      , direction = East
      , height = 10
      , id = 3
      , name = "Kameron"
      , score = 0
      , width = 10
      , x = 100
      , y = 300
      }
    ]
