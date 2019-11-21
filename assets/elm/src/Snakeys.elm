module Snakeys exposing (main)

-- IMPORTS

import Browser
import Browser.Events
import Color
import Html exposing (Html)
import Html.Attributes
import Json.Decode
import Player exposing (Player)
import Svg exposing (..)
import Svg.Attributes exposing (..)



-- MAIN


main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }



-- MODEL


type alias Item =
    { color : String
    , x : Int
    , y : Int
    }


type alias Model =
    { item : Item
    , playerKeyPress : Maybe String
    , players : List Player
    , window : Window
    }


type alias Window =
    { backgroundColor : String
    , x : Int
    , y : Int
    , width : Int
    , height : Int
    }


initialModel : Model
initialModel =
    { item =
        { color = "pink"
        , x = 400
        , y = 400
        }
    , playerKeyPress = Nothing
    , players = Player.playerData
    , window =
        { backgroundColor = "black"
        , x = 0
        , y = 0
        , width = 800
        , height = 600
        }
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( initialModel
    , Cmd.none
    )



-- UPDATE


type Msg
    = GameLoop Float
    | PlayerPressedKeyDown String
    | PlayerPressedKeyUp String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GameLoop frame ->
            let
                updatedPlayers =
                    model.players
                        |> List.map (updatePlayerDirection model.playerKeyPress)
                        |> List.map updatePlayerPosition
                        |> List.map (updatePlayerScore model.item)
            in
            ( { model | players = updatedPlayers }, Cmd.none )

        PlayerPressedKeyDown key ->
            ( { model | playerKeyPress = Just key }
            , Cmd.none
            )

        PlayerPressedKeyUp _ ->
            ( { model | playerKeyPress = Nothing }
            , Cmd.none
            )


playerFoundItem : Item -> Player -> Bool
playerFoundItem item player =
    player.x > item.x


updatePlayerDirection : Maybe String -> Player -> Player
updatePlayerDirection maybeKeyPress player =
    case ( player.direction, maybeKeyPress ) of
        ( Player.North, Just "ArrowLeft" ) ->
            { player | direction = Player.West }

        ( Player.North, Just "ArrowRight" ) ->
            { player | direction = Player.East }

        ( Player.North, _ ) ->
            player

        ( Player.East, Just "ArrowLeft" ) ->
            { player | direction = Player.North }

        ( Player.East, Just "ArrowRight" ) ->
            { player | direction = Player.South }

        ( Player.East, _ ) ->
            player

        ( Player.South, Just "ArrowLeft" ) ->
            { player | direction = Player.East }

        ( Player.South, Just "ArrowRight" ) ->
            { player | direction = Player.West }

        ( Player.South, _ ) ->
            player

        ( Player.West, Just "ArrowLeft" ) ->
            { player | direction = Player.South }

        ( Player.West, Just "ArrowRight" ) ->
            { player | direction = Player.North }

        ( Player.West, _ ) ->
            player


updatePlayerPosition : Player -> Player
updatePlayerPosition player =
    case player.direction of
        Player.North ->
            { player | y = player.y - 1 }

        Player.East ->
            { player | x = player.x + 1 }

        Player.South ->
            { player | y = player.y + 1 }

        Player.West ->
            { player | x = player.x - 1 }


updatePlayerScore : Item -> Player -> Player
updatePlayerScore item player =
    case playerFoundItem item player of
        True ->
            { player
                | score = player.score + 1
                , width = player.width + 1
            }

        False ->
            player



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Browser.Events.onAnimationFrameDelta GameLoop
        , Browser.Events.onKeyDown (Json.Decode.map PlayerPressedKeyDown keyDecoder)
        , Browser.Events.onKeyUp (Json.Decode.map PlayerPressedKeyUp keyDecoder)
        ]


keyDecoder : Json.Decode.Decoder String
keyDecoder =
    Json.Decode.field "key" Json.Decode.string



-- VIEW


view : Model -> Html a
view model =
    Html.div []
        [ Html.h1 [ Html.Attributes.class "font-black text-5xl" ]
            [ Html.text "Snakey" ]
        , playersList model.players
        , gameWindow model.item model.players model.window
        ]


playersList : List Player -> Html a
playersList players =
    players
        |> List.sortBy .score
        |> List.reverse
        |> List.map playersListItem
        |> Html.ul []


playersListItem : Player -> Html a
playersListItem player =
    let
        colorBoxClasses =
            "bg-" ++ Color.toString player.color ++ "-400" ++ " border border-2 border-black h-4 inline-block mx-2 w-4"
    in
    Html.li []
        [ Html.span [ Html.Attributes.class colorBoxClasses ]
            []
        , Html.span [ Html.Attributes.class "inline-block mx-2" ]
            [ Html.img
                [ Html.Attributes.class "h-4 w-4", Html.Attributes.src player.avatarUrl ]
                []
            ]
        , Html.span []
            [ Html.text player.name ]
        , Html.span [ Html.Attributes.class "px-2" ]
            [ Html.text (String.fromInt player.score) ]
        ]


gameWindow : Item -> List Player -> Window -> Svg a
gameWindow item players window =
    let
        viewBoxString =
            [ window.x
            , window.y
            , window.width
            , window.height
            ]
                |> List.map String.fromInt
                |> String.join " "
    in
    Html.div [ Html.Attributes.class "p-2" ]
        [ svg
            [ viewBox viewBoxString
            , width <| String.fromInt window.width
            , height <| String.fromInt window.height
            ]
            ([ viewGameWindow window ]
                ++ viewPlayers players
                ++ [ viewItem item ]
            )
        ]


viewGameWindow : Window -> Svg msg
viewGameWindow window =
    rect
        [ fill window.backgroundColor
        , x <| String.fromInt window.x
        , y <| String.fromInt window.y
        , width <| String.fromInt window.width
        , height <| String.fromInt window.height
        ]
        []


viewItem : Item -> Svg msg
viewItem item =
    rect
        [ fill item.color
        , x <| String.fromInt item.x
        , y <| String.fromInt item.y
        , width "10"
        , height "10"
        ]
        []


viewPlayers : List Player -> List (Svg msg)
viewPlayers players =
    List.map viewPlayer players


viewPlayer : Player -> Svg msg
viewPlayer player =
    rect
        [ fill <| Color.toTailwindHex player.color
        , x <| String.fromInt player.x
        , y <| String.fromInt player.y
        , width <| String.fromInt player.width
        , height <| String.fromInt player.height
        ]
        []
