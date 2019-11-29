module Snakeys exposing (main)

-- IMPORTS

import Browser
import Browser.Events
import Color exposing (Color)
import Direction exposing (Direction)
import Html exposing (Html)
import Html.Attributes
import Item exposing (Item)
import Json.Decode
import Player exposing (Player)
import Position exposing (Position)
import Random
import Snake exposing (Snake)
import Svg exposing (..)
import Svg.Attributes exposing (..)
import Window exposing (Window)



-- MAIN


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }



-- MODEL


type alias Food =
    { x : Int
    , y : Int
    }


type GameState
    = StartScreen
    | Playing
    | GameOverScreen


type alias Snakey =
    { score : Int
    , x : Int
    , y : Int
    }


type alias Model =
    -- { items : List Item
    -- , playerKeyPress : Maybe String
    -- , players : List Player
    -- , window : Window
    -- }
    { food : Food
    , gameState : GameState
    , playerKeyPress : Maybe String
    , snakey : Snakey
    , window : Window
    }


initialModel : Model
initialModel =
    -- { items = Item.itemData
    -- , playerKeyPress = Nothing
    -- , players = Player.playerData
    -- , window = Window.windowData
    -- }
    { food = { x = 100, y = 100 }
    , gameState = StartScreen
    , playerKeyPress = Nothing
    , snakey = { score = 0, x = 10, y = 10 }
    , window = Window.windowData
    }


scale : Int
scale =
    10


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
    | SpawnFood ( Int, Int )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GameLoop frame ->
            let
                randomGeneratorX =
                    Random.int scale (model.window.width - scale)

                randomGeneratorY =
                    Random.int scale (model.window.height - scale)

                snakeyOutOfBounds x y =
                    x == 0 || y == 0 || x == model.window.width - scale || y == model.window.height - scale
            in
            if model.snakey.x == model.food.x && model.snakey.y == model.food.y then
                ( { model | snakey = incrementSnakeyScore model.snakey }
                , Random.generate SpawnFood (Random.pair randomGeneratorX randomGeneratorY)
                )

            else if snakeyOutOfBounds model.snakey.x model.snakey.y then
                ( { model | gameState = GameOverScreen }
                , Cmd.none
                )

            else
                ( { model | snakey = updateSnakePosition model.window model.playerKeyPress model.snakey }
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

        SpawnFood ( x, y ) ->
            ( { model | food = updateFoodPosition x y model.food }
            , Cmd.none
            )


incrementSnakeyScore : Snakey -> Snakey
incrementSnakeyScore snakey =
    { snakey | score = snakey.score + 1 }



-- checkDirectionChange : Direction -> Snake -> Direction.Validity
-- checkDirectionChange newDirection snake =
--     case snake.direction of
--         Direction.Up ->
--             if newDirection /= Direction.Down then
--                 Direction.Valid
--             else
--                 Direction.Invalid
--         Direction.Right ->
--             if newDirection /= Direction.Left then
--                 Direction.Valid
--             else
--                 Direction.Invalid
--         Direction.Down ->
--             if newDirection /= Direction.Up then
--                 Direction.Valid
--             else
--                 Direction.Invalid
--         Direction.Left ->
--             if newDirection /= Direction.Right then
--                 Direction.Valid
--             else
--                 Direction.Invalid


playerFoundItem : Item -> Player -> Bool
playerFoundItem item player =
    let
        offset =
            10
    in
    (player.snake.head.x == item.position.x + offset) || (player.snake.head.x == item.position.x - offset)



-- updateGameState : Model -> Model
-- updateGameState model =
--     { model
--         | items = updateItems model model.items
--         , players = updatePlayers model model.players
--     }


updateItems : Model -> List Item -> List Item
updateItems model items =
    List.map updateItemPosition items


updateItemPosition : Item -> Item
updateItemPosition item =
    -- { item | position =
    --     { x = item.position.x + 1
    --     , y = item.position.y + 1
    --     }
    -- }
    { item | position = item.position }


updatePlayerScore : Player -> Player
updatePlayerScore player =
    { player | score = player.score + 1 }



-- updatePlayers : Model -> List Player -> List Player
-- updatePlayers model players =
--     players
--         |> List.map
--             (updatePlayerSnake model.playerKeyPress
--                 >> updatePlayerScore
--             )
-- updatePlayerSnake : Maybe String -> Player -> Player
-- updatePlayerSnake maybeKeyPress player =
--     { player
--         | snake =
--             player.snake
--                 |> (updateSnakeHead
--                         >> updateSnakeTail
--                         >> updateSnakeDirection maybeKeyPress
--                    )
--     }


updateFoodPosition : Int -> Int -> Food -> Food
updateFoodPosition newX newY food =
    { food
        | x = roundFoodPositionToScale newX
        , y = roundFoodPositionToScale newY
    }


roundFoodPositionToScale : Int -> Int
roundFoodPositionToScale foodPositionInt =
    if modBy scale foodPositionInt == 0 then
        foodPositionInt

    else
        foodPositionInt // scale * scale


updateSnakePosition : Window -> Maybe String -> Snakey -> Snakey
updateSnakePosition window maybeKeyPress snakey =
    case maybeKeyPress of
        Just "ArrowUp" ->
            { snakey | y = snakey.y - scale }

        Just "ArrowRight" ->
            { snakey | x = snakey.x + scale }

        Just "ArrowDown" ->
            { snakey | y = snakey.y + scale }

        Just "ArrowLeft" ->
            { snakey | x = snakey.x - scale }

        _ ->
            snakey


updateSnakeHead : Snake -> Snake
updateSnakeHead snake =
    { snake | head = updateSnakeHeadPosition snake }


updateSnakeTail : Snake -> Snake
updateSnakeTail snake =
    { snake | tail = updateSnakeTailPosition snake }


updateSnakeHeadPosition : Snake -> Position
updateSnakeHeadPosition { direction, head } =
    case direction of
        Direction.Up ->
            { head | y = head.y - 2 }

        Direction.Right ->
            { head | x = head.x + 2 }

        Direction.Down ->
            { head | y = head.y + 2 }

        Direction.Left ->
            { head | x = head.x - 2 }


updateSnakeTailPosition : Snake -> List Position
updateSnakeTailPosition { direction, tail } =
    List.map (updateSnakeTailSegment direction) tail


updateSnakeTailSegment : Direction -> Position -> Position
updateSnakeTailSegment direction tailSegment =
    case direction of
        Direction.Up ->
            { tailSegment | y = tailSegment.y - 2 }

        Direction.Right ->
            { tailSegment | x = tailSegment.x + 2 }

        Direction.Down ->
            { tailSegment | y = tailSegment.y + 2 }

        Direction.Left ->
            { tailSegment | x = tailSegment.x - 2 }



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
            [ Html.text "Snakeys" ]

        -- , playersList model.players
        , gameWindow model.snakey model.food model.gameState model.window
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


gameWindow : Snakey -> Food -> GameState -> Window -> Svg a
gameWindow snakey food gameState window =
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
            [ viewGameWindow window
            , viewSnakey snakey
            , viewFood food
            , case gameState of
                StartScreen ->
                    viewText (window.width // 2 - 100) (window.height // 2 - 40) "Press SPACEBAR to start!"

                Playing ->
                    text_ [] []

                GameOverScreen ->
                    viewText (window.width // 2 - 100) (window.height // 2 - 40) "☠️ Game Over. Press SPACEBAR to start over!"
            ]
        ]


viewText : Int -> Int -> String -> Svg a
viewText positionX positionY message =
    text_
        [ fill "white"
        , Html.Attributes.style "font-family" "Courier"
        , x <| String.fromInt positionX
        , y <| String.fromInt positionY
        ]
        [ text message ]


viewFood : Food -> Svg msg
viewFood food =
    rect
        [ fill <| "red"
        , x <| String.fromInt food.x
        , y <| String.fromInt food.y
        , width "10"
        , height "10"
        ]
        []


viewSnakey : Snakey -> Svg msg
viewSnakey snakey =
    rect
        [ fill <| "green"
        , x <| String.fromInt snakey.x
        , y <| String.fromInt snakey.y
        , width "10"
        , height "10"
        ]
        []


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
    List.map viewPlayerSnake players


viewPlayerSnake : Player -> Svg msg
viewPlayerSnake player =
    player
        |> viewSnakeHead
        |> List.singleton
        |> List.append (viewSnakeTail player)
        |> Svg.g []


viewSnakeHead : Player -> Svg msg
viewSnakeHead { snake } =
    viewSnakeSegment snake.color snake.head


viewSnakeTail : Player -> List (Svg msg)
viewSnakeTail { snake } =
    List.map (viewSnakeSegment snake.color) snake.tail


viewSnakeSegment : Color -> Position -> Svg msg
viewSnakeSegment color snakeSegment =
    rect
        [ fill <| Color.toTailwindHex color
        , x <| String.fromInt snakeSegment.x
        , y <| String.fromInt snakeSegment.y
        , width "10"
        , height "10"
        ]
        []
