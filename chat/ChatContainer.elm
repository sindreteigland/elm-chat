module ChatContainer exposing (..)

import Chat.Css as ChatCss
import Chat.Emoji exposing (..)
import Html exposing (..)
import Html.Attributes exposing (class, id, placeholder, src, style, value)
import Html.CssHelpers
import Html.Events exposing (on, onClick, onInput, onSubmit)
import Json.Decode as JD exposing (Decoder, field, float, int, maybe, string, succeed)
import Data exposing (..)
import ProfilePicture exposing (..)


{ id, class, classList } =
    Html.CssHelpers.withNamespace "rainchat"


chatContainer model =
    div [ class [ ChatCss.ChatContainer ] ]
        [ div [ style [ ( "display", "flex" ), ( "width", "100%" ), ( "height", "100%" ), ( "flex-direction", "column" ) ] ]
            [ chatView model
            , inputField model
            ]
        ]


chatView model =
    div [ id [ ChatCss.Chat ], onDivChanged ChatMessagesChanged ]
        (List.map viewMessage model.messages
         --|> List.reverse
        )


onDivChanged msg =
    on "DOMSubtreeModified" (JD.succeed msg)


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
                [ img
                    [ class [ ChatCss.ProfilePicture ]
                    , src user.picture
                    , style [ ( "border-color", user.color ), ( "margin-top", "15px" ) ]
                    ]
                    []

                --TODO switch to "real" profile pic
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


gifMessage url =
    div [ class [ ChatCss.GifMessage ] ]
        [ img [ src url, class [ ChatCss.Gif ] ] []
        ]


gifPicker =
    div [ id [ "gifPicker" ] ]
        (List.map mapGifs gifs)


mapGifs gif =
    img [ class [ "previewGif" ], src gif.prev, onClick <| GifClicked gif.gif ] [ text "no gif for u" ]


inputField model =
    div [ style [ ( "padding", "12px" ) ], class [ ChatCss.ElevationBorder ], onDivChanged ChatMessagesChanged ]
        [ form [ onSubmit SendMessage ]
            [ div [ class [ ChatCss.MessageArea ] ]
                (inputLayout model)
            ]
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
                [ input [ style [ ( "type", "text" ), ( "padding-top", "5px" ), ( "padding-bottom", "5px" ), ( "border-radius", "5px" ), ( "font-size", "medium" ) ], class [ ChatCss.Input ], placeholder "Say something...", onInput SetNewMessage, value model.newMessage.message ] []
                ]
            ]
        ]


expresionGroups model =
    div [ id [ "btn-group" ] ]
        [ button [ onClick <| Keyboard GifPicker ] [ text "Gifs" ]
        , button [ onClick <| Keyboard EmojiPicker ] [ text "Emoji" ]
        ]


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


mapEmojiCategories =
    List.map mapCategory emojis


mapCategory ( categoryTitle, emojis ) =
    div [ class [ " intercom-emoji-picker-group-title" ] ]
        [ text categoryTitle
        , div
            [ class
                [ " intercom-emoji-picker-group" ]
            , style [ ( "width", (ceiling (toFloat (List.length emojis) / 5) * 40 |> toString) ++ "px" ) ]
            ]
          <|
            List.map mapEmoji emojis
        ]


mapEmoji ( title, unicodeValue ) =
    div
        [ class
            [ " intercom-emoji-picker-emoji" ]
        , onClick <| EmojiClicked unicodeValue
        ]
        [ text unicodeValue ]
