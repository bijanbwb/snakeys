module Snakeys exposing (main)

-- IMPORTS

import Browser
import Browser.Events
import Html exposing (Html)
import Html.Attributes
import Json.Decode
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

type Direction
    = North
    | East
    | South
    | West

type alias Model =
    { playerKeyPress : Maybe String
    , players : List Player
    , window : Window
    }


type alias Player =
    { avatarUrl : String
    , color : String
    , direction : Direction
    , id : Int
    , name : String
    , score : Int
    , x : Int
    , y : Int
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
    { playerKeyPress = Nothing
    , players =
        [ { avatarUrl = "https://ca.slack-edge.com/T02A50N5X-U03CTQU93-c88640d8b72a-512"
          , color = "blue"
          , direction = East
          , id = 1
          , name = "Bijan"
          , score = 0
          , x = 100
          , y = 100
          }
        , { avatarUrl = "https://ca.slack-edge.com/T02A50N5X-UENQJLJTS-83d6e8679c9d-512"
          , color = "red"
          , direction = East
          , id = 1
          , name = "Nick"
          , score = 0
          , x = 100
          , y = 200
          }
        ]
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

updatePlayerDirection : Maybe String -> Player -> Player
updatePlayerDirection maybeKeyPress player =
    case (player.direction, maybeKeyPress) of
        (North, Just "ArrowLeft") -> { player | direction = West }
        (North, Just "ArrowRight") -> { player | direction = East }
        (North, _) -> player
        (East, Just "ArrowLeft") -> { player | direction = North }
        (East, Just "ArrowRight") -> { player | direction = South }
        (East, _) -> player
        (South, Just "ArrowLeft") -> { player | direction = East }
        (South, Just "ArrowRight") -> { player | direction = West }
        (South, _) -> player
        (West, Just "ArrowLeft") -> { player | direction = South }
        (West, Just "ArrowRight") -> { player | direction = North }
        (West, _) -> player


updatePlayerPosition : Player -> Player
updatePlayerPosition player =
    case player.direction of
        North -> { player | x = player.y - 1 }
        East -> { player | x = player.x + 1 }
        South -> { player | x = player.y + 1 }
        West -> { player | x = player.x - 1 }

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
        , gameWindow model.players model.window
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
            "bg-" ++ player.color ++ "-400" ++ " border border-2 border-black h-4 inline-block mx-2 w-4"
    in
    Html.li []
        [ Html.span [ Html.Attributes.class colorBoxClasses ]
            []
        , Html.span [ Html.Attributes.class "inline-block mx-2" ]
            [ Html.img
                [ Html.Attributes.class "h-4 w-4", Html.Attributes.src player.avatarUrl ] []
            ]
        , Html.span []
            [ Html.text player.name ]
        , Html.span [ Html.Attributes.class "px-2" ]
            [ Html.text (String.fromInt player.score) ]
        ]


gameWindow : List Player -> Window -> Svg a
gameWindow players window =
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


viewPlayers : List Player -> List (Svg msg)
viewPlayers players =
    List.map viewPlayer players


viewPlayer : Player -> Svg msg
viewPlayer player =
    rect
        [ fill player.color
        , x <| String.fromInt player.x
        , y <| String.fromInt player.y
        , width "10"
        , height "10"
        ]
        []
