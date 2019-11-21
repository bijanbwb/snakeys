module Item exposing
    ( Item
    , itemData
    )

-- IMPORTS

import Position exposing (Position)



-- TYPES


type alias Item =
    { color : String
    , position : Position
    }



-- DATA


itemData : List Item
itemData =
    [ { color = "pink"
      , position = { x = 400, y = 400 }
      }
    , { color = "yellow"
      , position = { x = 500, y = 500 }
      }
    ]
