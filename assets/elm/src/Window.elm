module Window exposing
    ( Window
    , windowData
    )

-- TYPES


type alias Window =
    { backgroundColor : String
    , x : Int
    , y : Int
    , width : Int
    , height : Int
    }



-- DATA


windowData : Window
windowData =
    { backgroundColor = "black"
    , x = 0
    , y = 0
    , width = 800
    , height = 600
    }
