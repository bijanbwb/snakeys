module Color exposing
    ( Color(..)
    , toString
    , toTailwindHex
    )

-- TYPES


type Color
    = Blue
    | Green
    | Red



-- HELPERS


toString : Color -> String
toString color =
    case color of
        Blue ->
            "blue"

        Green ->
            "green"

        Red ->
            "red"


toTailwindHex : Color -> String
toTailwindHex color =
    case color of
        Blue ->
            "#63B3ED"

        Green ->
            "#68D391"

        Red ->
            "#FC8181"
