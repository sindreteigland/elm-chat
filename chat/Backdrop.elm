module Backdrop exposing (..)

import Html exposing (..)
import Html.Attributes exposing (class, id, placeholder, src, style, value)
import Html.CssHelpers
import Html.Events exposing (on, onClick, onInput, onSubmit)


-- My Stuff

import Data exposing (..)
import List exposing (append)


backdrop : Bool -> Msg -> Html Msg
backdrop isOpen onClickEvent =
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
                (showBackdrop isOpen)
        , onClick <| onClickEvent
        ]
        []


showBackdrop isOpen =
    if isOpen == True then
        [ ( "opacity", "0.87" ), ( "visibility", "visible" ) ]
    else
        [ ( "opacity", "0" ), ( "visibility", "hidden" ) ]
