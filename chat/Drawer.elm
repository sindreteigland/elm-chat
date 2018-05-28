module Drawer exposing (..)

import DynamicStyle exposing (..)
import Html exposing (..)
import Html.Attributes exposing (class, id, placeholder, src, style, value)
import Html.CssHelpers
import Html.Events exposing (on, onClick, onInput, onSubmit)
import List exposing (append)


-- My Stuff

import Backdrop exposing (..)
import Data exposing (..)
import Chat.Css as ChatCss
import ProfilePicture exposing (..)


{ id, class, classList } =
    Html.CssHelpers.withNamespace "rainchat"


leftMenu model =
    div [ style [ ( "z-index", "10" ) ] ] [ backdrop model.leftMenuOpen LeftMenuToggle, drawer model ]


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


details model =
    div [ style [ ( "background-color", "#171717" ), ( "display", "flex" ), ( "flex-direction", "column" ), ( "min-width", "250px" ), ( "max-width", "420px" ), ( "height", "100%" ) ] ]
        [ div [ class [ ChatCss.ElevationBorder ], style [ ( "padding-top", "8px" ), ( "padding-bottom", "4px" ), ( "padding-left", "15px" ), ( "padding-right", "15px" ) ] ]
            [ searchField model ]
        , detailsContaier model

        --, profileContainer model
        ]


searchField model =
    div [ style [ ( "padding-bottom", "5px" ) ] ]
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
