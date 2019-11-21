module Snakeys exposing (main)

-- IMPORTS

import Browser
import Browser.Events
import Color
import Direction exposing (Direction)
import Html exposing (Html)
import Html.Attributes
import Item exposing (Item)
import Json.Decode
import Player exposing (Player)
import Position exposing (Position)
import Snake exposing (Snake)
import Svg exposing (..)
import Svg.Attributes exposing (..)
import Window exposing (Window)



-- MAIN


main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }



-- MODEL


type alias Model =
    { items : List Item
    , playerKeyPress : Maybe String
    , players : List Player
    , window : Window
    }


initialModel : Model
initialModel =
    { items = Item.itemData
    , playerKeyPress = Nothing
    , players = Player.playerData
    , window = Window.windowData
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
            ( updateGameState model
            , Cmd.none
            )

        PlayerPressedKeyDown key ->
            ( { model | playerKeyPress = Just key }
            , Cmd.none
            )

        PlayerPressedKeyUp _ ->
            ( { model | playerKeyPress = Nothing }
            , Cmd.none
            )


checkDirectionChange : Direction -> Snake -> Direction.Validity
checkDirectionChange newDirection snake =
    case snake.direction of
        Direction.Up ->
            if newDirection /= Direction.Down then
                Direction.Valid

            else
                Direction.Invalid

        Direction.Right ->
            if newDirection /= Direction.Left then
                Direction.Valid

            else
                Direction.Invalid

        Direction.Down ->
            if newDirection /= Direction.Up then
                Direction.Valid

            else
                Direction.Invalid

        Direction.Left ->
            if newDirection /= Direction.Right then
                Direction.Valid

            else
                Direction.Invalid


playerFoundItem : Item -> Player -> Bool
playerFoundItem item player =
    let
        offset =
            10
    in
    (player.snake.head.x == item.position.x + offset) || (player.snake.head.x == item.position.x - offset)


updateGameState : Model -> Model
updateGameState model =
    { model
        | items = updateItems model model.items
        , players = updatePlayers model model.players
    }


updateItems : Model -> List Item -> List Item
updateItems model items =
    List.map updateItemPosition items


updateItemPosition : Item -> Item
updateItemPosition item =
    { item | position = { x = item.position.x + 1, y = item.position.y + 1 } }


updatePlayerScore : Player -> Player
updatePlayerScore player =
    { player | score = player.score + 1 }


updatePlayers : Model -> List Player -> List Player
updatePlayers model players =
    players
        |> List.map
            (updatePlayerSnake model.playerKeyPress
                >> updatePlayerScore
            )


updatePlayerSnake : Maybe String -> Player -> Player
updatePlayerSnake maybeKeyPress player =
    { player
        | snake =
            player.snake
                |> (updateSnakeHead
                        >> updateSnakeDirection maybeKeyPress
                   )
    }


updateSnakeDirection : Maybe String -> Snake -> Snake
updateSnakeDirection maybeKeyPress snake =
    case maybeKeyPress of
        Just "ArrowUp" ->
            case checkDirectionChange Direction.Up snake of
                Direction.Valid ->
                    { snake | direction = Direction.Up }

                Direction.Invalid ->
                    snake

        Just "ArrowRight" ->
            case checkDirectionChange Direction.Right snake of
                Direction.Valid ->
                    { snake | direction = Direction.Right }

                Direction.Invalid ->
                    snake

        Just "ArrowDown" ->
            case checkDirectionChange Direction.Down snake of
                Direction.Valid ->
                    { snake | direction = Direction.Down }

                Direction.Invalid ->
                    snake

        Just "ArrowLeft" ->
            case checkDirectionChange Direction.Left snake of
                Direction.Valid ->
                    { snake | direction = Direction.Left }

                Direction.Invalid ->
                    snake

        _ ->
            snake


updateSnakeHead : Snake -> Snake
updateSnakeHead snake =
    { snake | head = updateSnakePosition snake }


updateSnakePosition : Snake -> Position
updateSnakePosition { direction, head } =
    case direction of
        Direction.Up ->
            { head | y = head.y - 1 }

        Direction.Right ->
            { head | x = head.x + 1 }

        Direction.Down ->
            { head | y = head.y + 1 }

        Direction.Left ->
            { head | x = head.x - 1 }



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
        , gameWindow model.items model.players model.window
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


gameWindow : List Item -> List Player -> Window -> Svg a
gameWindow items players window =
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
                ++ viewItems items
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


viewItems : List Item -> List (Svg msg)
viewItems itesm =
    List.map viewItem itesm


viewItem : Item -> Svg msg
viewItem item =
    rect
        [ fill item.color
        , x <| String.fromInt item.position.x
        , y <| String.fromInt item.position.y
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
        , x <| String.fromInt player.snake.head.x
        , y <| String.fromInt player.snake.head.y
        , width "10"
        , height "10"
        ]
        []
