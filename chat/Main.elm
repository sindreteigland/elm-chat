port module Main exposing (..)

import Chat.Css as ChatCss
import Chat.Emoji exposing (..)
import Data exposing (..)
import Html exposing (..)
import Html.Attributes exposing (class, id, placeholder, src, style, value)
import Html.CssHelpers
import Html.Events exposing (on, onClick, onInput, onSubmit)
import Json.Decode as JD exposing (Decoder, field, float, int, maybe, string, succeed)
import Json.Decode.Extra exposing ((|:))
import Json.Encode as JE
import List exposing (append)
import Phoenix.Channel
import Phoenix.Push
import Phoenix.Socket
import Regex exposing (contains, regex)
import String.Extra exposing (fromCodePoints, isBlank, toCodePoints)
import Task exposing (..)
import DynamicStyle exposing (..)
import List.Extra exposing (find)


{ id, class, classList } =
    Html.CssHelpers.withNamespace "rainchat"


type alias Model =
    { newMessage : NewMessage
    , messages : List ChatMessage
    , conversations : List Conversation
    , phxSocket : Phoenix.Socket.Socket Msg
    , userList : List User
    , currentUser : User
    , keyboard : KeyboardType
    , focusedChat : Conversation
    , leftMenuOpen : Bool
    }


type Msg
    = SetNewMessage String
    | JoinChannel
    | PhoenixMsg (Phoenix.Socket.Msg Msg)
    | SendMessage
    | ReciveChatMessage JE.Value
    | Keyboard KeyboardType
    | ChatMessagesChanged
    | EmojiClicked String
    | GifClicked String
    | BackSpace
    | ChangeChat Conversation
    | LeftMenuToggle


type KeyboardType
    = None
    | EmojiPicker
    | GifPicker


type alias NewMessage =
    { msgType : MessageType
    , message : String
    }


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


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case Debug.log "hei" msg of
        SetNewMessage string ->
            { model | newMessage = { msgType = model.newMessage.msgType, message = string } } ! []

        JoinChannel ->
            let
                channel =
                    Phoenix.Channel.init "room:lobby"

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


isEmotes string =
    if (toCodePoints string |> List.length) <= 5 then
        string
            |> toCodePoints
            |> List.all (\num -> num >= 65533)
    else
        False


urlRegex =
    regex "/^(?:http(s)?:\\/\\/)?[\\w.-]+(?:\\.[\\w\\.-]+)+[\\w\\-\\._~:/?#[\\]@!\\$&'\\(\\)\\*\\+,;=.]+$/gm"


homeMadeRetardUrlParser string =
    String.contains "http" string


isUrl string =
    homeMadeRetardUrlParser string


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


getUser : List User -> ChatMessage -> User
getUser users message =
    let
        user =
            users
                |> List.filter (.userId >> (==) message.userId)
                |> List.head
    in
        case user of
            Just user ->
                user

            Nothing ->
                { userId = "user1", userName = "Bob", color = "#25e075", picture = "unnamed.png" }


viewMessage : ChatMessage -> Html Msg
viewMessage message =
    let
        user =
            getUser users message
    in
        if user.userId == disUsr then
            --TODO use a real user and not this
            myMessage message
        else
            theireMessage user message


myMessage : ChatMessage -> Html Msg
myMessage message =
    case message.msgType of
        Text ->
            div [ class [ ChatCss.MessageContainer, ChatCss.MyMessageContainer ] ]
                [ div [ class [ ChatCss.Message, ChatCss.MyMessage, ChatCss.ElevationBorder ] ]
                    [ div [ class [ ChatCss.Square, ChatCss.MySquare ] ] []
                    , div [ class [ ChatCss.MessageBody ] ] [ text message.body ]
                    ]
                ]

        Gif ->
            div [ class [ ChatCss.MessageContainer, ChatCss.MyMessageContainer ] ]
                [ gifMessage message.body
                ]

        Emotes ->
            div [ class [ ChatCss.MessageContainer, ChatCss.MyMessageContainer ], style [ ( "font-size", "xx-large" ) ] ]
                [ p [ class [ ChatCss.EmoteContainer ] ] [ text message.body ]
                ]

        Unknown ->
            Html.text ""



--TODO Refactor shiet


theireMessage : User -> ChatMessage -> Html Msg
theireMessage user message =
    case message.msgType of
        Text ->
            div [ class [ ChatCss.MessageContainer ] ]
                [ div [ style [ ( "display", "flex" ), ( "flex-direction", "row" ) ] ]
                    [ div [ style [ ( "margin-top", "15px" ) ] ] [ profilePicture user.color user.picture ]
                    , div [ style [ ( "display", "flex" ), ( "flex-direction", "column" ) ] ]
                        [ div [ class [ ChatCss.UserName ] ] [ text <| user.userName ]
                        , div [ class [ ChatCss.Message, ChatCss.TheireMessage, ChatCss.ElevationBorder ] ]
                            [ div [ class [ ChatCss.Square, ChatCss.TheireSquare ] ] []
                            , div [ class [ ChatCss.MessageBody ] ] [ text message.body ]
                            ]
                        ]
                    ]
                ]

        Gif ->
            div [ class [ ChatCss.MessageContainer ] ]
                [ img [ class [ ChatCss.ProfilePicture ], src user.picture, style [ ( "border-color", user.color ), ( "margin-top", "15px" ) ] ] [] --TODO switch to "real" profile pic
                , div [ class [ ChatCss.UserName ] ] [ text <| user.userName ]
                , gifMessage message.body
                ]

        Emotes ->
            div [ class [ ChatCss.MessageContainer ] ]
                [ img [ class [ ChatCss.ProfilePicture ], src user.picture, style [ ( "border-color", user.color ) ] ] [] --TODO switch to "real" profile pic
                , div [ class [ ChatCss.UserName ] ] [ text <| user.userName ]
                , p [ class [ ChatCss.EmoteContainer ] ] [ text message.body ]
                ]

        Unknown ->
            Html.text ""


userProfile user =
    [ img [ class [ ChatCss.ProfilePicture ], src user.picture, style [ ( "border-color", user.color ) ] ] [] --TODO switch to "real" profile pic
    , div [ class [ ChatCss.UserName ] ] [ text <| user.userName ]
    ]


mapCategory ( categoryTitle, emojis ) =
    div [ class [ " intercom-emoji-picker-group-title" ] ]
        [ text categoryTitle
        , div [ class [ " intercom-emoji-picker-group" ], style [ ( "width", (ceiling (toFloat (List.length emojis) / 5) * 40 |> toString) ++ "px" ) ] ] <| List.map mapEmoji emojis
        ]


mapEmoji ( title, unicodeValue ) =
    div [ class [ " intercom-emoji-picker-emoji" ], onClick <| EmojiClicked unicodeValue ] [ text unicodeValue ]


mapEmojiCategories =
    List.map mapCategory emojis


emojiPicker =
    div []
        [ div [ id [ "emojiPanel" ] ] mapEmojiCategories
        , div [ class [ ChatCss.EmoteSection ] ]
            [ img [ src "ic_keyboard_hide_white_24px.svg", onClick <| Keyboard None ] []

            --TODO make this shiet mo betta
            , div [] [ text "🕔" ]
            , div [] [ text "😄" ]
            , div [] [ text "🐻" ]
            , div [] [ text "💡" ]
            , div [] [ text "🏫" ]
            , div [] [ text "❌" ]
            , img [ src "ic_backspace_white_24px.svg", onClick BackSpace ] []
            ]
        ]


mapGifs gif =
    img [ class [ "previewGif" ], src gif.prev, onClick <| GifClicked gif.gif ] [ text "no gif for u" ]


gifPicker =
    div [ id [ "gifPicker" ] ]
        (List.map mapGifs gifs)


gifMessage url =
    div [ class [ ChatCss.GifMessage ] ]
        [ img [ src url, class [ ChatCss.Gif ] ] []
        ]


none =
    div [ class [ ChatCss.EmoteSection ] ]
        [ img [ src "ic_tag_faces_white_24px.svg", onClick <| Keyboard EmojiPicker ] []
        , img [ src "ic_gif_white_24px.svg", onClick <| Keyboard GifPicker ] []
        , img [ id [ ChatCss.Send ], src "ic_send_white_24px.svg", onClick BackSpace ] []
        ]


messageArea model =
    div []
        [ div []
            [ div [ style [ ( "position", "relative" ), ( "display", "flex" ), ( "align-content", "stretch" ), ( "flex-direction", "column" ) ] ]
                [ input [ style [ ( "type", "text" ), ( "padding-top", "10px" ), ( "padding-bottom", "10px" ), ( "border-radius", "5px" ) ], class [ ChatCss.Input ], placeholder "Say something...", onInput SetNewMessage, value model.newMessage.message ] []
                ]
            ]
        ]


expresionGroups model =
    div [ id [ "btn-group" ] ]
        [ button [ onClick <| Keyboard GifPicker ] [ text "Gifs" ]
        , button [ onClick <| Keyboard EmojiPicker ] [ text "Emoji" ]
        ]


inputLayout : Model -> List (Html Msg)
inputLayout model =
    case model.keyboard of
        None ->
            [ messageArea model ]

        EmojiPicker ->
            [ messageArea model
            , expresionGroups model
            , emojiPicker
            ]

        GifPicker ->
            [ gifPicker
            , messageArea model
            , expresionGroups model
            ]


onDivChanged msg =
    on "DOMSubtreeModified" (JD.succeed msg)


verticalToolbar =
    div
        [ style
            [ ( "background-color", "#2665D7" )
            , ( "width", "50px" )
            , ( "height", "100%" )
            , ( "display", "flex" )
            , ( "flex-direction", "column" )
            , ( "box-shadow", "0 0 0 rgba(0,0,0,0), 0 1px 2px rgba(0,0,0,0.24)" )
            , ( "align-items", "center" )
            , ( "padding", "5px" )
            ]
        , class [ ChatCss.ElevationBorder ]
        ]
        [ div [ style [ ( "font-size", "small" ) ] ] [ text "name?" ]
        , div [ style [ ( "text-align", "center" ) ] ] [ img [ src "icons/users-group.svg", onClick BackSpace, style [ ( "width", "25px" ) ] ] [] ]
        , div [ style [ ( "font-size", "small" ) ] ] [ text "0 online" ]
        , div
            [ style
                [ ( "width", "40px" )
                , ( "border", "white" )
                , ( "border-style", "solid" )
                , ( "border-width", "1px" )
                , ( "border-radius", "30px" )
                ]
            ]
            []
        , div [] [ img [ src "icons/plus.svg", onClick BackSpace, style [ ( "width", "35px" ), ( "margin", "2.5px" ) ] ] [] ]

        --, div [] [ img [ src "icons/plus.svg", onClick BackSpace, style [ ( "width", "45px" ), ( "margin", "2.5px" ) ] ] [] ]
        ]


details model =
    div [ style [ ( "background-color", "#171717" ), ( "display", "flex" ), ( "flex-direction", "column" ), ( "min-width", "250px" ), ( "max-width", "420px" ), ( "height", "100%" ) ] ]
        [ div [ class [ ChatCss.ElevationBorder ], style [ ( "padding-top", "8px" ), ( "padding-bottom", "4px" ), ( "padding-left", "15px" ), ( "padding-right", "15px" ) ] ]
            [ searchField model ]
        , detailsContaier model

        --, profileContainer model
        ]


detailsContaier model =
    div
        [ style
            [ ( "margin", "10px" )
            , ( "height", "100%" )
            , ( "color", "white" )
            ]
        ]
        [ p [ style [ ( "font-size", "small" ) ] ] [ text "DIRECT MESSAGES" ]
        , conversationList model
        ]


conversationList model =
    div [ style [ ( "display", "flex" ), ( "flex-direction", "column" ) ] ]
        (List.map
            (conversationListElement
                model.focusedChat
            )
            model.conversations
        )



--conversationListElement : Conversation -> Html Msg


conversationListElement focused conversation =
    div [ onClick <| ChangeChat conversation ]
        [ div
            (hover_
                [ ( "width", "100%" )
                , ( "height", "45px" )
                , ( "display", "flex" )
                , ( "flex-direction", "row" )
                , ( "align-items", "center" )
                , ( "margin-top", "2px" )
                , ( "margin-bottom", "2px" )
                , ( "border-radius", "2px" )
                , ( "padding", "2px" )
                , ( "transition", "all 450ms cubic-bezier(0.23, 1, 0.32, 1) 0ms" )
                ]
                (isFocused
                    focused.conversationId
                    conversation.conversationId
                )
            )
            [ profilePicture conversation.color conversation.picture
            , text conversation.conversationName
            ]
        ]


isFocused focusId currentId =
    if focusId == currentId then
        [ ( "color", "white", "white" )
        , ( "background-color", "#404040", "#404040" )
        , ( "cursor", "", "pointer" )
        ]
    else
        [ ( "color", "dimgrey", "white" ), ( "background-color", "", "#252525" ), ( "cursor", "", "pointer" ) ]


searchField model =
    div [ style [ ( "padding-bottom", "5px" ) ], onDivChanged ChatMessagesChanged ]
        [ form [ onSubmit SendMessage ]
            [ div [ class [ ChatCss.MessageArea ] ] [ searchArea model ]
            ]
        ]


searchArea model =
    div []
        [ div []
            [ div [ style [ ( "position", "relative" ), ( "display", "flex" ), ( "align-content", "stretch" ), ( "flex-direction", "column" ) ] ]
                [ input [ style [ ( "type", "text" ), ( "padding-top", "10px" ), ( "padding-bottom", "10px" ), ( "border-radius", "5px" ) ], class [ ChatCss.Input ], placeholder "Find or start a conversation", onInput SetNewMessage, value model.newMessage.message ] []
                ]
            ]
        ]


profileContainer model =
    div [ class [ ChatCss.InputContainer, ChatCss.ElevationBorder ], style [ ( "display", "flex" ), ( "height", "45px" ) ] ]
        [ profilePicture model.currentUser.color model.currentUser.picture
        , div [ class [ ChatCss.InputField ] ]
            [ label [ class [ ChatCss.UserName ] ] [ text model.currentUser.userName ] ]
        ]


profilePicture color picture =
    img [ class [ ChatCss.ProfilePicture ], src picture, style [ ( "border-color", color ) ] ] []



--TODO: Move this and the logic for it to its own file


members =
    div
        [ style
            [ ( "background-color", "#171717" )
            , ( "min-width", "200px" )
            , ( "padding", "10px" )
            , ( "max-width", "472px" )
            , ( "height", "100%" )
            ]
        ]
        [ text "Members/Images/options/other stuff that can be usefull wil go here... we will just see here!" ]



--TODO: Move this and the logic for it to its own file


drawer model =
    div
        [ style
            [ ( "display", "flex" )
            , ( "height", "100%" )
            , ( "position", "absolute" )
            , ( "transition", "all 450ms cubic-bezier(0.23, 1, 0.32, 1) 0ms" )
            , drawerPosition model.leftMenuOpen
            ]
        ]
        [ --verticalToolbar
          details model
        ]


drawerPosition isOpen =
    if isOpen == True then
        ( "left", "0px" )
    else
        ( "left", "-250px" )


showBackdrop isOpen =
    if isOpen == True then
        [ ( "opacity", "0.87" ), ( "visibility", "visible" ) ]
    else
        [ ( "opacity", "0" ), ( "visibility", "hidden" ) ]


backdrop model =
    div
        [ style <|
            append
                [ ( "width", "100%" )
                , ( "height", "100%" )
                , ( "background-color", "black" )
                , ( "opacity", "0.87" )
                , ( "position", "absolute" )
                , ( "transition", "all 450ms cubic-bezier(0.23, 1, 0.32, 1) 0ms" )
                ]
                (showBackdrop model.leftMenuOpen)
        , onClick <| LeftMenuToggle
        ]
        []


leftMenu model =
    div [ style [ ( "z-index", "10" ) ] ] [ backdrop model, drawer model ]


inputField model =
    div [ style [ ( "padding", "12px" ) ], class [ ChatCss.ElevationBorder ], onDivChanged ChatMessagesChanged ]
        [ form [ onSubmit SendMessage ]
            [ div [ class [ ChatCss.MessageArea ] ]
                (inputLayout model)
            ]
        ]



--TODO: Move this and the logic for it to its own file???


appBar title =
    div [ class [ ChatCss.ToolBar, ChatCss.ElevationBorder ], style [ ( "display", "flex" ) ] ]
        [ div
            append (hover_
                [ ( "font-size", "20px" )
                , ( "font-face", "Droid Sans Mono" )
                , ("margin", "15px")
                ]
                [ ( "cursor", "", "pointer" ) ]
            )
            [ img [ src "icons/baseline-menu.svg", onClick <| LeftMenuToggle ] [] ]
        , p [] [ text title ]
        ]


chatView model =
    div [ id [ ChatCss.Chat ], onDivChanged ChatMessagesChanged ]
        (List.map viewMessage model.messages
         --|> List.reverse
        )


mainView model =
    div [ style [ ( "display", "flex" ), ( "flex-direction", "column" ), ( "width", ("100%") ) ] ]
        [ appBar model.focusedChat.conversationName
        , div [ style [ ( "display", "flex" ), ( "height", "100%" ) ] ]
            [ chatContainer model

            --, members
            ]
        ]


chatContainer model =
    div [ class [ ChatCss.ChatContainer ] ]
        [ div [ style [ ( "display", "flex" ), ( "width", "100%" ), ( "height", "100%" ), ( "flex-direction", "column" ) ] ]
            [ chatView model
            , inputField model
            ]
        ]


view : Model -> Html Msg
view model =
    div [ style [ ( "display", "flex" ), ( "width", "100%" ), ( "justify-content", "center" ) ] ]
        [ --backdrop
          -- drawer model
          leftMenu model
        , mainView model
        ]



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
