port module Main exposing (appBar, blankMessage, chatMessageDecoder, getMessageType, homeMadeRetardUrlParser, init, initialModel, isEmotes, isUrl, join, main, mainView, messageTypeDecoder, scrollBottom, socketServer, update, view)

import Browser
import Chat.Emoji exposing (..)
import Data exposing (..)
import Html exposing (..)
import Html.Attributes exposing (class, id, placeholder, src, style, value)
import Html.Events exposing (on, onClick, onInput, onSubmit)
import Json.Decode as JD exposing (Decoder, field, float, int, maybe, string, succeed)
import Json.Decode.Extra exposing (..)
import Json.Encode as JE
import List exposing (append)
import List.Extra exposing (find)
import String.Extra exposing (fromCodePoints, isBlank, toCodePoints)
import Task exposing (..)


type alias Model =
    { newMessage : NewMessage
    , messages : List ChatMessage
    , conversations : List Conversation
    , userList : List User
    , currentUser : User
    , keyboard : KeyboardType
    , focusedChat : Conversation
    , leftMenuOpen : Bool
    }


initialModel : Model
initialModel =
    { newMessage = blankMessage
    , messages = messages4
    , conversations = conversations
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


init : () -> ( Model, Cmd Msg )
init _ =
    ( initialModel, Cmd.none )


type Msg
    = SetNewMessage String
    | JoinChannel
    | SendMessage
    | ReciveChatMessage JE.Value
    | Keyboard KeyboardType
    | ChatMessagesChanged
    | EmojiClicked String
    | GifClicked String
    | BackSpace
    | ChangeChat Conversation
    | LeftMenuToggle


socketServer : String
socketServer =
    "ws://127.0.0.1:4000/socket/websocket"


blankMessage =
    { msgType = Unknown, message = "" }


join : Msg -> Cmd Msg
join msg =
    Task.succeed msg
        |> Task.perform identity


port scrollBottom : String -> Cmd msg



-- fjern main, skal eksponere subscriptions, Model, Msg og update


main =
    Browser.element
        { init = init
        , update = update
        , view = view
        , subscriptions = \_ -> Sub.none
        }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case Debug.log "Debug log: " msg of
        SetNewMessage string ->
            ( { model | newMessage = { msgType = model.newMessage.msgType, message = string } }
            , Cmd.none
            )

        JoinChannel ->
            ( model, Cmd.none )

        SendMessage ->
            case isBlank model.newMessage.message of
                True ->
                    ( { model | newMessage = blankMessage }, Cmd.none )

                False ->
                    let
                        payload =
                            "json payload here"
                    in
                    ( { model
                        | newMessage = blankMessage
                        , keyboard = None
                      }
                    , Cmd.none
                    )

        ReciveChatMessage raw ->
            ( model, Cmd.none )

        ChatMessagesChanged ->
            ( model, scrollBottom "wee" )

        Keyboard keyboard ->
            ( { model | keyboard = keyboard }, Cmd.none )

        EmojiClicked emoji ->
            ( { model | newMessage = { msgType = model.newMessage.msgType, message = model.newMessage.message ++ emoji } }, Cmd.none )

        GifClicked gifUrl ->
            { model | newMessage = { msgType = Gif, message = gifUrl } } |> update SendMessage

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
            (model, Cmd.none)
--            ( { model | focusedChat = conversation, leftMenuOpen = False, messages = conversation.messages }, Cmd.none )

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


chatMessageDecoder =
    "json"


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



-- FROM CHATCONTAINER


profilePicture color picture =
    img [ class "rainchatProfilePicture", src picture, style "border-color" color ] []


chatContainer : Model -> Html Msg
chatContainer model =
    div [ class "rainchatChatContainer" ]
        [ div [ style "display" "flex", style "width" "100%", style "height" "100%", style "flex-direction" "column" ]
            [ chatView model
            , inputField model
            ]
        ]



-- ChatCss.Chat doesnt exist anymore?


chatView model =
    div [ id "1", onDivChanged ChatMessagesChanged ]
        (List.map viewMessage model.messages
         --|> List.reverse
        )


onDivChanged msg =
    on "DOMSubtreeModified" (JD.succeed msg)


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


getUser : List User -> ChatMessage -> User
getUser users message =
    let
        user =
            users
                |> List.filter (.userId >> (==) message.userId)
                |> List.head
    in
    case user of
        Just u ->
            u

        Nothing ->
            { userId = "user1", userName = "Bob", color = "#25e075", picture = "unnamed.png" }


myMessage : ChatMessage -> Html msg
myMessage message =
    case message.msgType of
        Text ->
            div [ class "rainchatMessageContainer rainchatMyMessageContainer" ]
                [ div [ class "rainchatMessage rainchatMyMessage rainchatElevationBorder" ]
                    [ div [ class "rainchatSquare rainchatMySquare" ] []
                    , div [ class "rainchatMessageBody" ] [ text message.body ]
                    ]
                ]

        Gif ->
            div [ class "rainchatMessageContainer rainchatMyMessageContainer" ]
                [ gifMessage message.body
                ]

        Emotes ->
            div [ class "rainchatMessageContainer rainchatMyMessageContainer", style "font-size" "xx-large" ]
                [ p [ class "rainchatEmoteContainer" ] [ text message.body ]
                ]

        Unknown ->
            Html.text ""



--TODO Refactor shiet


theireMessage : User -> ChatMessage -> Html msg
theireMessage user message =
    case message.msgType of
        Text ->
            div [ class "rainchatMessageContainer" ]
                [ div [ style "display" "flex", style "flex-direction" "row" ]
                    [ div [ style "margin-top" "15px" ] [ profilePicture user.color user.picture ]
                    , div [ style "display" "flex", style "flex-direction" "column" ]
                        [ div [ class "rainchatUserName" ] [ text <| user.userName ]
                        , div [ class "rainchatMessage rainchatTheireMessage rainchatElevationBorder" ]
                            [ div [ class "rainchatSquare rainchatTheireSquare" ] []
                            , div [ class "rainchatMessageBody" ] [ text message.body ]
                            ]
                        ]
                    ]
                ]

        Gif ->
            div [ class "rainchatMessageContainer" ]
                [ img
                    [ class "rainchatProfilePicture"
                    , src user.picture
                    , style "border-color" user.color
                    , style "margin-top" "15px"
                    ]
                    []

                --TODO switch to "real" profile pic
                , div [ class "rainchatUserName" ] [ text <| user.userName ]
                , gifMessage message.body
                ]

        Emotes ->
            div [ class "rainchatMessageContainer" ]
                [ img [ class "rainchatProfilePicture", src user.picture, style "border-color" user.color ] [] --TODO switch to "real" profile pic
                , div [ class "rainchatUserName" ] [ text <| user.userName ]
                , p [ class "rainchatEmoteContainer" ] [ text message.body ]
                ]

        Unknown ->
            Html.text ""


gifMessage url =
    div [ class "rainchatGifMessage" ]
        [ img [ src url, class "rainchatGif" ] []
        ]


mapGifs gif gifClicked =
    img [ class "previewGif", src gif.prev, onClick <| gifClicked gif.gif ] [ text "no gif for u" ]


inputField : Model -> Html Msg
inputField model =
    div [ style "padding" "12px", class "rainchatElevationBorder", onDivChanged ChatMessagesChanged ]
        [ form [ onSubmit SendMessage ]
            [ div [ class "rainchatMessageArea" ]
                [ messageArea model ]
            ]
        ]


none =
    div [ class "rainchatEmoteSection" ]
        [ img [ src "ic_tag_faces_white_24px.svg", onClick <| Keyboard EmojiPicker ] []
        , img [ src "ic_gif_white_24px.svg", onClick <| Keyboard GifPicker ] []
        , img [ id "rainchatSend", src "ic_send_white_24px.svg", onClick BackSpace ] []
        ]


messageArea : Model -> Html Msg
messageArea model =
    div []
        [ div []
            [ div [ style "position" "relative", style "display" "flex", style "align-content" "stretch", style "flex-direction" "column" ]
                [ input
                    [ style "type" "text"
                    , style "padding-top" "5px"
                    , style "padding-bottom" "5px"
                    , style "border-radius" "5px"
                    , style "font-size" "medium"
                    , class "rainchatInput"
                    , placeholder "Say something..."
                    , onInput SetNewMessage
                    , value model.newMessage.message
                    ]
                    []
                ]
            ]
        ]



-- /FROM CHATCOINTER


view : Model -> Html Msg
view model =
    div [ style "display" "flex", style "width" "100%", style "justify-content" "center" ]
        [ mainView model
        ]


mainView model =
    div [ style "display" "flex", style "flex-direction" "column", style "width" "100%" ]
        [ appBar model.focusedChat.conversationName
        , div [ style "display" "flex", style "height" "100%" ]
            [ chatContainer model

            --, members
            ]
        ]


appBar title =
    div [ class "rainChatToolBar rainChatElevationBorder", style "display" "flex" ]
        [ --TODO: include sick hover style
          div
            -- (hover_
            --     [ ( "font-size", "20px" )
            --     , ( "font-face", "Droid Sans Mono" )
            --     , ( "margin", "15px" )
            --     ]
            --     [ ( "cursor", "", "pointer" ) ]
            -- )
            []
            [ img [ src "icons/baseline-menu.svg", onClick <| LeftMenuToggle ] [] ]
        , p [] [ text title ]
        ]
