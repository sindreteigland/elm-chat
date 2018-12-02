port module Chat exposing (Model, Msg, init, initialModel, update, view)

import Browser
import Browser.Dom as Dom
import Data exposing (..)
import Html exposing (..)
import Html.Attributes exposing (attribute, class, id, placeholder, src, style, value)
import Html.Events exposing (on, onClick, onInput, onSubmit)
import Json.Decode as JD exposing (Decoder, field, float, int, maybe, string, succeed)
import Json.Decode.Extra exposing (..)
import Json.Encode as JE
import List exposing (append)
import List.Extra exposing (find)
import String.Extra exposing (fromCodePoints, isBlank, toCodePoints)
import Task exposing (..)
import Theme exposing (..)


type alias Model =
    { newMessage : NewMessage
    , messages : List ChatMessage
    , conversations : List Conversation
    , userList : List User
    , currentUser : User
    , focusedChat : Conversation
    , leftMenuOpen : Bool
    , theme : List ( String, String )
    }


initialModel : Model
initialModel =
    { newMessage = blankMessage
    , messages = messages4
    , conversations = conversations
    , userList = users
    , currentUser = { userId = "user3", userName = "Jelly kid", color = "#673AB7", picture = "b0ce1e9c577d40ee25fe3aeea4798561.jpg" }
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
    , theme = Theme.chill
    }


init : Model
init =
    initialModel


type Msg
    = SetNewMessage String
    | JoinChannel
    | SendMessage
    | ReciveChatMessage JE.Value
    | NoOp
    | ScrollToEnd
    | ColorHack (List ( String, String ))


blankMessage =
    { msgType = Unknown, message = "" }


join : Msg -> Cmd Msg
join msg =
    Task.succeed msg
        |> Task.perform identity


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case Debug.log "Debug log: " msg of
        NoOp ->
            ( model, Cmd.none )

        SetNewMessage string ->
            ( { model | newMessage = { msgType = model.newMessage.msgType, message = string } }
            , Cmd.none
            )

        JoinChannel ->
            ( model, Cmd.none )

        ScrollToEnd ->
            let
                elementId =
                    "messages-container"

                cmd =
                    Dom.getViewportOf elementId
                        |> Task.andThen (\viewport -> Dom.setViewportOf elementId 0 viewport.scene.height)
                        |> Task.attempt (\_ -> NoOp)
            in
            ( model, cmd )

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
                      }
                    , Cmd.none
                    )

        ReciveChatMessage raw ->
            ( model, Cmd.none )

        ColorHack newTheme ->
            ( { model | theme = newTheme }, Cmd.none )


setCssCustomProperties =
    attribute "class" "hest"



--    ( { model | focusedChat = conversation, leftMenuOpen = False, messages = conversation.messages }, Cmd.none )


type alias RGB =
    { red : Int
    , green : Int
    , blue : Int
    }


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
    img [ class "profile-picture", src picture, style "border-color" color ] []



-- ChatCss.Chat doesnt exist anymore?


chatView : Model -> Html Msg
chatView model =
    div [ id "messages-container", onDivChanged ScrollToEnd ]
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

        --  TODO: this needs to handle unknown user and not just give  you Bob
        Nothing ->
            { userId = "user1", userName = "Bob", color = "#25e075", picture = "unnamed.png" }


theireMessageContainer user content =
    div [ class "message-container" ]
        [ div [ style "display" "flex" ]
            [ div [ style "margin-top" "15px" ]
                [ profilePicture user.color user.picture ]
            , div [ style "display" "flex", style "flex-direction" "column" ]
                [ div [ class "chat-username" ] [ text <| user.userName ]
                , content
                ]
            ]
        ]


chatMessage message cssClass =
    div [ class <| "chat-bubble fancy-border " ++ cssClass ]
        [ div [ class "square" ] []
        , p [] [ text message ]
        ]


gifMessage url =
    div [ class "image-container fancy-border" ]
        [ img [ src url ] []
        ]


emojiMessage message =
    p [ class "just-emoji" ] [ text message ]


myMessage : ChatMessage -> Html msg
myMessage message =
    case message.msgType of
        Text ->
            div [ class "message-container move-right" ]
                [ chatMessage message.body "my-message" ]

        Gif ->
            div [ class "message-container move-right" ]
                [ gifMessage message.body
                ]

        Emotes ->
            div [ class "message-container move-right", style "font-size" "xx-large" ]
                [ emojiMessage message.body ]

        Unknown ->
            Html.text ""


theireMessage : User -> ChatMessage -> Html msg
theireMessage user message =
    case message.msgType of
        Text ->
            theireMessageContainer user (chatMessage message.body "theire-message")

        Gif ->
            theireMessageContainer user (gifMessage message.body)

        Emotes ->
            theireMessageContainer user (emojiMessage message.body)

        Unknown ->
            Html.text ""


inputField : Model -> Html Msg
inputField model =
    div [ style "padding" "12px", class "input-bar fancy-border", onDivChanged ScrollToEnd ]
        [ form [ onSubmit SendMessage ]
            [ div [ class "chat-message-area" ]
                [ messageArea model ]
            ]
        ]


messageArea : Model -> Html Msg
messageArea model =
    div [ setCssCustomProperties ]
        [ div []
            [ div [ style "position" "relative", style "display" "flex", style "align-content" "stretch", style "flex-direction" "column" ]
                [ input
                    [ style "type" "text"
                    , style "padding-top" "5px"
                    , style "padding-bottom" "5px"
                    , style "border-radius" "5px"
                    , style "font-size" "medium"
                    , class "chat-inputbar"
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
    div [ class "chat-container", customCssProperties model.theme ]
        [ --appBar model.focusedChat.conversationName
        themeBar
        , chatView model
        , inputField model
        --, button [ onClick <| ColorHack Theme.defaultTheme ] [ text "Scroll to bottom" ]
        ]


themeBar =
    div [ class "temp" ]
        [ button [ onClick <| ColorHack Theme.defaultTheme ] [ text "Default" ]
        , button [ onClick <| ColorHack Theme.bobafett ] [ text "Boba Fett" ]
        , button [ onClick <| ColorHack Theme.chill ] [ text "Chill" ]
        ]


appBar title =
    div [ class "chat-appbar" ]
        [ h1 [] [ text title ]
        ]
