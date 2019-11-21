module Player exposing
    ( Player
    , playerData
    )

-- IMPORTS

import Color exposing (Color)
import Direction exposing (Direction)
import Position exposing (Position)
import Snake exposing (Snake)



-- TYPES


type alias Player =
    { avatarUrl : String
    , color : Color
    , id : Int
    , name : String
    , score : Int
    , snake : Snake
    }



-- DATA


playerData : List Player
playerData =
    [ { avatarUrl = "https://ca.slack-edge.com/T02A50N5X-U03CTQU93-c88640d8b72a-512"
      , color = Color.Blue
      , id = 1
      , name = "Bijan"
      , score = 0
      , snake =
            { color = Color.Blue
            , direction = Direction.Right
            , head = { x = 100, y = 100 }
            , tail = []
            }
      }
    ]
