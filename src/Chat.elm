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
    { currentUser : User
    , messages : List ChatMessage
    , newMessage : NewMessage
    , theme : Theme
    , users : List User
    }


initialModel : Model
initialModel =
    { currentUser = { userId = "user3", userName = "Jelly kid", color = "#673AB7", picture = "b0ce1e9c577d40ee25fe3aeea4798561.jpg" }
    , messages = messages4
    , newMessage = blankMessage
    , theme = Chill
    , users = users
    }


init : ( Model, Cmd Msg )
init =
    ( initialModel, scrollToEnd )


type Msg
    = SetTheme Theme.Theme
    | JoinChannel
    | NoOp
    | ReciveChatMessage JE.Value
    | ScrollToEnd
    | SendMessage
    | SetNewMessage String


elementId =
    "messages-container"


blankMessage =
    { msgType = Unknown, message = "" }


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



--TODO fix url parser


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


scrollToEnd : Cmd Msg
scrollToEnd =
    Dom.getViewportOf elementId
        |> Task.andThen (\viewport -> Dom.setViewportOf elementId 0 viewport.scene.height)
        |> Task.attempt (\_ -> NoOp)


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
            --maybe not needed if chat doesnt handle socket stuff
            ( model, Cmd.none )

        ScrollToEnd ->
            ( model, scrollToEnd )

        SendMessage ->
            case isBlank model.newMessage.message of
                True ->
                    ( { model | newMessage = blankMessage }, Cmd.none )

                False ->
                    -- sett payload and send it to the handler, then clean newMessage
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
            --decode raw from json to a message
            ( model, Cmd.none )

        SetTheme newTheme ->
            ( { model | theme = newTheme }, Cmd.none )


chatMessage message cssClass =
    div [ class <| "chat-bubble fancy-border " ++ cssClass ]
        [ p [] [ text message ]
        ]


gifMessage url =
    div [ class "image-container fancy-border" ]
        [ img [ src url ] []
        ]


emojiMessage message =
    p [ class "just-emoji" ] [ text message ]


profilePicture color picture =
    img [ class "profile-picture", src picture, style "border-color" color ] []


myMessageConatiner _ content =
    div [ class "message-container move-right" ]
        [ content ]


theireMessageContainer user content =
    div [ class "message-container" ]
        [ div []
            [ div [ style "margin-top" "15px" ]
                [ profilePicture user.color user.picture ]
            , div [ style "display" "flex", style "flex-direction" "column" ]
                [ div [ class "chat-username" ] [ text <| user.userName ]
                , content
                ]
            ]
        ]


createMsgContainer container user message msgClass =
    case message.msgType of
        Text ->
            container user (chatMessage message.body msgClass)

        Gif ->
            container user (gifMessage message.body)

        Emotes ->
            container user (emojiMessage message.body)

        Unknown ->
            Html.text ""


viewMessage message =
    let
        user =
            getUser users message
    in
    if user.userId == disUsr then
        createMsgContainer myMessageConatiner user message "my-message"

    else
        createMsgContainer theireMessageContainer user message "theire-message"


messageArea : Model -> Html Msg
messageArea model =
    div [ id "messages-container" ]
        (List.map viewMessage model.messages)


inputField : Model -> Html Msg
inputField model =
    input
        [ class "chat-inputbar"
        , placeholder "Say something..."
        , onInput SetNewMessage
        , value model.newMessage.message
        ]
        []


inputArea : Model -> Html Msg
inputArea model =
    div [ class "input-area fancy-border" ]
        [ form [ onSubmit SendMessage ]
            [ div [ class "chat-message-area" ]
                [ inputField model ]
            ]
        ]


view : Model -> Html Msg
view model =
    div [ class "chat-container", getTheme model.theme ]
        [ messageArea model
        , inputArea model
        ]
