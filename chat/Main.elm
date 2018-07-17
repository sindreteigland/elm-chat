port module Main exposing (..)

import DynamicStyle exposing (..)
import Html exposing (..)
import Html.Attributes exposing (class, id, placeholder, src, style, value)
import Html.CssHelpers
import Html.Events exposing (on, onClick, onInput, onSubmit)
import Json.Decode as JD exposing (Decoder, field, float, int, maybe, string, succeed)
import Json.Decode.Extra exposing ((|:))
import Json.Encode as JE
import List exposing (append)
import List.Extra exposing (find)
import Phoenix.Channel
import Phoenix.Push
import Phoenix.Socket
import Regex exposing (contains, regex)
import String.Extra exposing (fromCodePoints, isBlank, toCodePoints)
import Task exposing (..)


-- My Stuff

import Chat.Css as ChatCss
import Chat.Emoji exposing (..)
import Data exposing (..)
import Drawer exposing (..)
import ChatContainer exposing (..)


{ id, class, classList } =
    Html.CssHelpers.withNamespace "rainchat"


initialModel : Model
initialModel =
    { newMessage = blankMessage
    , messages = messages4
    , conversations = conversations
    , phxSocket = initPhxSocket
    , userList = users
    , currentUser = { userId = "user3", userName = "Jelly kid", color = "#673AB7", picture = "b0ce1e9c577d40ee25fe3aeea4798561.jpg" }
    , keyboard = None
    , focusedChat =
        { conversationId = "4"
        , conversationType = Group
        , color = "#673AB7"
        , users = users
        , conversationName = "The Boyz"
        , picture = "0.jpg"
        , messages = messages4
        }
    , leftMenuOpen = False
    }


socketServer : String
socketServer =
    "ws://127.0.0.1:4000/socket/websocket"


blankMessage =
    { msgType = Unknown, message = "" }


initPhxSocket : Phoenix.Socket.Socket Msg
initPhxSocket =
    Phoenix.Socket.init socketServer
        |> Phoenix.Socket.withDebug
        |> Phoenix.Socket.on "new:msg" "room:lobby" ReciveChatMessage



-- TODO: maybe change this way of trigging the join-channel thingy


join : msg -> Cmd msg
join msg =
    Task.succeed msg
        |> Task.perform identity


port scrollBottom : String -> Cmd msg


main =
    Html.program
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }


subscriptions : Model -> Sub Msg
subscriptions model =
    Phoenix.Socket.listen model.phxSocket PhoenixMsg


init : ( Model, Cmd Msg )
init =
    ( initialModel, join JoinChannel )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case Debug.log "Debug log: " msg of
        SetNewMessage string ->
            { model | newMessage = { msgType = model.newMessage.msgType, message = string } } ! []

        JoinChannel ->
            let
                channel =
                    Phoenix.Channel.init "room:4"

                ( phxSocket, phxCmd ) =
                    Phoenix.Socket.join channel model.phxSocket
            in
                ( { model | phxSocket = phxSocket }
                , Cmd.map PhoenixMsg phxCmd
                )

        PhoenixMsg msg ->
            let
                ( phxSocket, phxCmd ) =
                    Phoenix.Socket.update msg model.phxSocket
            in
                ( { model | phxSocket = phxSocket }
                , Cmd.map PhoenixMsg phxCmd
                )

        SendMessage ->
            case isBlank model.newMessage.message of
                True ->
                    ( { model | newMessage = blankMessage }, Cmd.none )

                False ->
                    let
                        payload =
                            --TODO include messagetype to send with the payload
                            JE.object [ ( "user", JE.string model.currentUser.userId ), ( "messageType", JE.string <| toString <| getMessageType model.newMessage.message ), ( "body", JE.string model.newMessage.message ) ]

                        push_ =
                            Phoenix.Push.init "new:msg" "room:lobby"
                                |> Phoenix.Push.withPayload (Debug.log "das paylopad" payload)

                        ( phxSocket, phxCmd ) =
                            Phoenix.Socket.push push_ model.phxSocket
                    in
                        ( { model
                            | newMessage = blankMessage
                            , phxSocket = phxSocket
                            , keyboard = None
                          }
                        , Cmd.map PhoenixMsg phxCmd
                        )

        ReciveChatMessage raw ->
            case JD.decodeValue chatMessageDecoder raw of
                Ok chatMessage ->
                    { model | messages = append model.messages [ chatMessage ] } ! []

                Err error ->
                    let
                        noe =
                            Debug.log "msg error" error
                    in
                        model ! []

        ChatMessagesChanged ->
            ( model, scrollBottom "wee" )

        Keyboard keyboard ->
            ( { model | keyboard = keyboard }, Cmd.none )

        EmojiClicked emoji ->
            ( { model | newMessage = { msgType = model.newMessage.msgType, message = model.newMessage.message ++ emoji } }, Cmd.none )

        GifClicked gifUrl ->
            ({ model | newMessage = { msgType = Gif, message = gifUrl } } |> update SendMessage)

        BackSpace ->
            let
                --String.dropRight only works on UTF8 chars. Thats a problem with emotes.
                shave =
                    toCodePoints model.newMessage.message
                        |> List.reverse
                        |> List.drop 1
                        |> List.reverse
                        |> fromCodePoints
            in
                ( { model | newMessage = { msgType = model.newMessage.msgType, message = shave } }, Cmd.none )

        ChangeChat conversation ->
            ( { model | focusedChat = conversation, leftMenuOpen = False, messages = conversation.messages }, Cmd.none )

        LeftMenuToggle ->
            ( { model | leftMenuOpen = not model.leftMenuOpen }, Cmd.none )


getMessageType msg =
    case isEmotes msg of
        True ->
            Emotes

        False ->
            case Debug.log "url me" (isUrl msg) of
                True ->
                    Gif

                False ->
                    Text


isEmotes string =
    if (toCodePoints string |> List.length) <= 5 then
        string
            |> toCodePoints
            |> List.all (\num -> num >= 65533)
    else
        False


isUrl string =
    homeMadeRetardUrlParser string


homeMadeRetardUrlParser string =
    String.contains "http" string



--TODO Doesn't work, need to make a GODLIKE regex


urlRegex =
    regex "/^(?:http(s)?:\\/\\/)?[\\w.-]+(?:\\.[\\w\\.-]+)+[\\w\\-\\._~:/?#[\\]@!\\$&'\\(\\)\\*\\+,;=.]+$/gm"


chatMessageDecoder : JD.Decoder ChatMessage
chatMessageDecoder =
    JD.succeed ChatMessage
        |: field "user" JD.string
        |: (field "messageType" JD.string
                |> JD.andThen messageTypeDecoder
           )
        |: field "body" JD.string


messageTypeDecoder msgType =
    JD.succeed <|
        case msgType of
            "Text" ->
                Text

            "Emotes" ->
                Emotes

            "Gif" ->
                Gif

            _ ->
                Unknown


view : Model -> Html Msg
view model =
    div [ style [ ( "display", "flex" ), ( "width", "100%" ), ( "justify-content", "center" ) ] ]
        [ --backdrop
          -- drawer model
          leftMenu model --TODO Make drawer the "master" element
        , mainView model
        ]


mainView model =
    div [ style [ ( "display", "flex" ), ( "flex-direction", "column" ), ( "width", ("100%") ) ] ]
        [ appBar model.focusedChat.conversationName
        , div [ style [ ( "display", "flex" ), ( "height", "100%" ) ] ]
            [ chatContainer model

            --, members
            ]
        ]


appBar title =
    div [ class [ ChatCss.ToolBar, ChatCss.ElevationBorder ], style [ ( "display", "flex" ) ] ]
        [ div
            (hover_
                [ ( "font-size", "20px" )
                , ( "font-face", "Droid Sans Mono" )
                , ( "margin", "15px" )
                ]
                [ ( "cursor", "", "pointer" ) ]
            )
            [ img [ src "icons/baseline-menu.svg", onClick <| LeftMenuToggle ] [] ]
        , p [] [ text title ]
        ]



-- members =
--     div
--         [ style
--             [ ( "background-color", "#171717" )
--             , ( "min-width", "200px" )
--             , ( "padding", "10px" )
--             , ( "max-width", "472px" )
--             , ( "height", "100%" )
--             ]
--         ]
--         [ text "Members/Images/options/other stuff that can be usefull wil go here... we will just see here!" ]
-- verticalToolbar =
--     div
--         [ style
--             [ ( "background-color", "#2665D7" )
--             , ( "width", "50px" )
--             , ( "height", "100%" )
--             , ( "display", "flex" )
--             , ( "flex-direction", "column" )
--             , ( "box-shadow", "0 0 0 rgba(0,0,0,0), 0 1px 2px rgba(0,0,0,0.24)" )
--             , ( "align-items", "center" )
--             , ( "padding", "5px" )
--             ]
--         , class [ ChatCss.ElevationBorder ]
--         ]
--         [ div [ style [ ( "font-size", "small" ) ] ] [ text "name?" ]
--         , div [ style [ ( "text-align", "center" ) ] ] [ img [ src "icons/users-group.svg", onClick BackSpace, style [ ( "width", "25px" ) ] ] [] ]
--         , div [ style [ ( "font-size", "small" ) ] ] [ text "0 online" ]
--         , div
--             [ style
--                 [ ( "width", "40px" )
--                 , ( "border", "white" )
--                 , ( "border-style", "solid" )
--                 , ( "border-width", "1px" )
--                 , ( "border-radius", "30px" )
--                 ]
--             ]
--             []
--         , div [] [ img [ src "icons/plus.svg", onClick BackSpace, style [ ( "width", "35px" ), ( "margin", "2.5px" ) ] ] [] ]
--         --, div [] [ img [ src "icons/plus.svg", onClick BackSpace, style [ ( "width", "45px" ), ( "margin", "2.5px" ) ] ] [] ]
--         ]
