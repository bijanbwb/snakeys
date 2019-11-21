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
            , head = { x = 10, y = 100 }
            , tail =
                List.range 0 8
                    |> List.map (\n -> { x = negate n * 10, y = 100 })
            }
      }
    , { avatarUrl = "https://ca.slack-edge.com/T02A50N5X-UENQJLJTS-83d6e8679c9d-512"
      , color = Color.Red
      , id = 2
      , name = "Nick"
      , score = 0
      , snake =
            { color = Color.Red
            , direction = Direction.Right
            , head = { x = 10, y = 200 }
            , tail =
                List.range 0 8
                    |> List.map (\n -> { x = negate n * 10, y = 200 })
            }
      }
    , { avatarUrl = "https://ca.slack-edge.com/T02A50N5X-UEBNS4XTL-1f772791e268-512"
      , color = Color.Green
      , id = 3
      , name = "Kameron"
      , score = 0
      , snake =
            { color = Color.Green
            , direction = Direction.Right
            , head = { x = 10, y = 300 }
            , tail =
                List.range 0 8
                    |> List.map (\n -> { x = negate n * 10, y = 300 })
            }
      }
    ]
