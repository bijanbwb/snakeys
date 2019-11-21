module Snake exposing (Snake)

-- IMPORTS

import Color exposing (Color)
import Direction exposing (Direction)
import Position exposing (Position)



-- TYPES


type alias Snake =
    { color : Color
    , direction : Direction
    , head : Position
    , tail : List Position
    }
