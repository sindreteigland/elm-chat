module ChatContainer exposing (chatContainer, chatView, getUser, gifMessage, gifPicker, inputField, mapGifs, messageArea, myMessage, none, onDivChanged, theireMessage, viewMessage)

-- import Chat.Css as ChatCss
import Chat.Emoji exposing (..)
import Data exposing (..)
import Html exposing (..)
import Html.Attributes exposing (class, id, placeholder, src, style, value)
-- import Html.CssHelpers
import Html.Events exposing (on, onClick, onInput, onSubmit)
import Json.Decode as JD exposing (Decoder, field, float, int, maybe, string, succeed)
-- import ProfilePicture exposing (..)


-- { id, class, classList } =
--     Html.CssHelpers.withNamespace "rainchat"


profilePicture color picture =
    img [ class "rainchatProfilePicture" , src picture, style "border-color" color ] []

chatContainer model =
    div [ class "rainchatChatContainer" ]
        [ div [ style "display" "flex", style "width" "100%", style "height" "100%", style "flex-direction" "column" ]
            [ chatView model
            , inputField model
            ]
        ]


chatView : List ChatMessage -> msg -> Html msg
chatView messages chatMessageChanged =
    div [ id "rainchatChat", onDivChanged chatMessageChanged ]
        (List.map viewMessage messages
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
                [ div [ class "rainchatMessage rainchatMyMessage rainchatElevationBorder"  ]
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
            div [ class  "rainchatMessageContainer"  ]
                [ div [ style "display" "flex", style "flex-direction" "row" ]
                    [ div [ style "margin-top" "15px" ] [ profilePicture user.color user.picture ]
                    , div [ style "display" "flex", style "flex-direction" "column" ]
                        [ div [ class  "rainchatUserName" ] [ text <| user.userName ]
                        , div [ class  "rainchatMessage rainchatTheireMessage rainchatElevationBorder" ]
                            [ div [ class "rainchatSquare rainchatTheireSquare"  ] []
                            , div [ class "rainchatMessageBody" ] [ text message.body ]
                            ]
                        ]
                    ]
                ]

        Gif ->
            div [ class "rainchatMessageContainer"  ]
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


gifPicker =
    div [ id "gifPicker" ]
        (List.map mapGifs gifs)


mapGifs gif gifClicked =
    img [ class "previewGif", src gif.prev, onClick <| gifClicked gif.gif ] [ text "no gif for u" ]


inputField : newMessage -> msg -> msg -> Html msg
inputField newMessage changeMsg submitMsg =
    div [ style "padding" "12px", class "rainchatElevationBorder", onDivChanged changeMsg ]
        [ form [ onSubmit submitMsg ]
            [ div [ class "rainchatMessageArea" ]
                [ messageArea newMessage]
            ]
        ]


-- inputLayout : Model -> List (Html msg)
-- inputLayout model =
--     case model.keyboard of
--         None ->
--             [ messageArea model ]

--         EmojiPicker ->
--             [ messageArea model
--             , expresionGroups model
--             , emojiPicker
--             ]

--         GifPicker ->
--             [ gifPicker
--             , messageArea model
--             , expresionGroups model
--             ]


none =
    div [ class "rainchatEmoteSection" ]
        [ img [ src "ic_tag_faces_white_24px.svg", onClick <| Keyboard EmojiPicker ] []
        , img [ src "ic_gif_white_24px.svg", onClick <| Keyboard GifPicker ] []
        , img [ id "rainchatSend", src "ic_send_white_24px.svg", onClick BackSpace ] []
        ]



messageArea : NewMessage -> msg -> Html msg
messageArea newMessage setNewMessage =
    div []
        [ div []
            [ div [ style "position" "relative", style "display" "flex", style "align-content" "stretch", style "flex-direction" "column" ]
                [ input [ style "type" "text", style "padding-top" "5px", style "padding-bottom" "5px", style "border-radius" "5px", style "font-size" "medium", 
                class "rainchatInput", placeholder "Say something...", onInput SetNewMessage, value model.newMessage.message ] []
                ]
            ]
        ]


-- expresionGroups model =
--     div [ id [ "btn-group" ] ]
--         [ button [ onClick <| Keyboard GifPicker ] [ text "Gifs" ]
--         , button [ onClick <| Keyboard EmojiPicker ] [ text "Emoji" ]
--         ]


-- emojiPicker =
--     div []
--         [ div [ id"emojiPanel" ] mapEmojiCategories
--         , div [ class "rainchatEmoteSection" ]
--             [ img [ src "ic_keyboard_hide_white_24px.svg", onClick <| Keyboard None ] []

--             --TODO make this shiet mo betta
--             , div [] [ text "🕔" ]
--             , div [] [ text "😄" ]
--             , div [] [ text "🐻" ]
--             , div [] [ text "💡" ]
--             , div [] [ text "🏫" ]
--             , div [] [ text "❌" ]
--             , img [ src "ic_backspace_white_24px.svg", onClick BackSpace ] []
--             ]
--         ]


-- mapEmojiCategories =
--     List.map mapCategory emojis


-- mapCategory ( categoryTitle, emojis ) =
--     div [ class [ " intercom-emoji-picker-group-title" ] ]
--         [ text categoryTitle
--         , div
--             [ class
--                 [ " intercom-emoji-picker-group" ]
--             , style "width" ((ceiling (toFloat (List.length emojis) / 5) * 40 |> toString) ++ "px")
--             ]
--           <|
--             List.map mapEmoji emojis
--         ]


-- mapEmoji ( title, unicodeValue ) =
--     div
--         [ class
--             [ " intercom-emoji-picker-emoji" ]
--         , onClick <| EmojiClicked unicodeValue
--         ]
--         [ text unicodeValue ]
