module Chat.Css exposing (..)

import Css exposing (..)
import Css.Elements exposing (..)
import Css.Namespace exposing (..)


type CssClasses
    = ChatContainer
    | ToolBar
    | MessageContainer
    | MyMessageContainer
    | ProfilePicture
    | UserName
    | Square
    | TheireSquare
    | MySquare
    | Message
    | TheireMessage
    | MyMessage
    | MessageBody
    | InputContainer
    | Input
    | MyPicture
    | InputField
    | MessageArea
    | EmoteSection
    | GifMessage
    | Gif
    | EmoteContainer
    | ElevationBorder


type CssIds
    = Chat
    | Send
    | SmileyEmote


type alias Theme =
    { level1 : Css.Color
    , level2 : Css.Color
    , level3 : Css.Color
    , level4 : Css.Color
    }


type alias Elevation =
    { e0 : Mixin
    , e1 : Mixin
    , e2 : Mixin
    , e3 : Mixin
    , e4 : Mixin
    , e5 : Mixin
    }



-- DEFAULT COLOR SCHEME


currentTheme =
    darkTheme


primaryColor =
    hex "2665D7"


accentColor =
    hex "9ac933"


elevation =
    { e0 = boxShadowX "0"
    , e1 = boxShadowX "0 0 0 rgba(0,0,0,0), 0 1px 2px rgba(0,0,0,0.24)"
    , e2 = boxShadowX "0 3px 6px rgba(0,0,0,0.16), 0 3px 6px rgba(0,0,0,0.23)"
    , e3 = boxShadowX "0 10px 20px rgba(0,0,0,0.19), 0 6px 6px rgba(0,0,0,0.23)"
    , e4 = boxShadowX "0 14px 28px rgba(0,0,0,0.25), 0 10px 10px rgba(0,0,0,0.22)"
    , e5 = boxShadowX "0 19px 38px rgba(0,0,0,0.30), 0 15px 12px rgba(0,0,0,0.22)"
    }


lightTheme =
    { level1 = hex "E0E0E0"
    , level2 = hex "F5F5F5"
    , level3 = hex "FAFAFA"
    , level4 = hex "FFFFFF"
    }


darkTheme =
    { level1 = hex "000000"
    , level2 = hex "212121"
    , level3 = hex "303030"
    , level4 = hex "424242"
    }


unpack cssValue =
    cssValue


css =
    (stylesheet << namespace "rainchat")
        [ body
            []
        , class ChatContainer
            [ displayFlex
            , flexDirection column
            , backgroundColor currentTheme.level2
            , contrastColor currentTheme.level2
            , width (pct 100)

            -- , maxWidth (px 850)
            , height (pct 100)
            , borderRadius (px 2)
            , justifyContent spaceBetween
            ]
        , class ToolBar
            [ backgroundColor currentTheme.level4
            , contrastColor primaryColor
            , fontSize large

            -- , height (px 62)
            , width (pct 100)
            , borderRadius4 (px 2) (px 2) (px 0) (px 0)
            , elevation.e1
            , zIndex 2

            --, children [ p [ paddingLeft (px 10) ] ]
            ]
        , id Chat
            [ overflowY scroll
            , property "-webkit-overflow-scrolling" "touch"
            , flexDirection column
            , height (pct 100)
            ]
        , class MessageContainer
            [ padding4 (px 5) (px 10) (px 5) (px 10)
            ]
        , class MyMessageContainer
            [ displayFlex
            , justifyContent flexEnd
            , paddingTop (px 15)
            , paddingBottom (px 15)
            ]
        , class ProfilePicture
            [ float left
            , marginRight (px 10)

            --, marginTop (px 15)
            , width (px 35)
            , height (px 35)
            , border (px 3)
            , borderRadius (pct 50)
            , borderStyle solid
            , borderColor (hex "006cb7") -- TODO remove ma, is default color
            , elevation.e2
            ]
        , class UserName
            [ fontSize (pt 10)
            ]
        , class Square
            [ width (px 12)
            , height (px 12)

            -- transform: rotate(45deg) TODO make this elm-css compatible
            , position absolute
            , borderRadius (px 2)
            , marginTop (px 7)
            ]
        , class TheireSquare
            [ backgroundColor primaryColor
            , marginLeft (px -8.5)
            ]
        , class MySquare
            [ backgroundColor accentColor
            , right (px 0)
            , marginRight (px -3)
            ]
        , class Message
            [ position relative
            , borderRadius (px 2)
            , elevation.e2
            , padding (px 5)
            , display inlineBlock
            , maxWidth (px 700)
            ]
        , class GifMessage
            [ position relative
            , display inlineBlock
            ]
        , class TheireMessage
            [ backgroundColor primaryColor
            , contrastColor primaryColor --TODO Color based on Background
            ]
        , class MyMessage
            [ backgroundColor accentColor
            , contrastColor accentColor --TODO Color based on Background
            ]
        , class MessageBody
            [ display block
            , overflow auto
            , overflowX hidden
            , textOverflow ellipsis
            , padding (px 5)
            , fontSize medium
            , margin (px 0)
            ]
        , class InputContainer
            [ backgroundColor currentTheme.level3
            , contrastColor currentTheme.level3
            , height auto
            , padding (px 10)
            , borderRadius4 (px 0) (px 0) (px 2) (px 2)
            , elevation.e1
            , border (px 1)
            , borderStyle solid
            , borderTopColor (hex "3c3c3c")
            , borderRightColor transparent
            , borderBottomColor transparent
            , borderLeftColor transparent
            ]
        , class Input
            [ border (px 0)
            , padding (px 5)

            --, width (pct 90)
            , backgroundColor currentTheme.level3
            , contrastColor currentTheme.level3
            ]
        , form
            [ displayFlex
            , flexDirection column

            --, color (hex "fff") --TODO Color based on Background
            ]
        , class MyPicture
            [ marginTop (px 0)
            ]
        , class InputField
            [ displayFlex
            , flexDirection column
            , width (pct 100)
            , children [ class UserName [ paddingLeft (px 5) ] ]
            , marginLeft (px 5)
            , marginRight (px 5)
            ]
        , class MessageArea
            [ displayFlex
            , flexDirection column
            ]
        , class EmoteSection
            [ displayFlex
            , flexDirection row

            --, color (hex "fff")
            , margin4 (px 10) (px 0) (px 0) (px 5)
            , justifyContent spaceBetween
            ]
        , id Send
            [ marginLeft (px 15)
            , marginTop (px 14)
            , width (px 30)
            ]
        , id SmileyEmote
            [ position absolute
            , top (px -1)
            , right (px 15)
            ]
        , class Gif
            [ height (pct 100)
            , width (pct 100)
            , borderRadius (px 2)
            , maxWidth (px 200)
            , maxHeight (px 200)
            ]
        , class EmoteContainer
            [ fontSize xxLarge
            , margin (px 0)
            ]
        , class ElevationBorder
            [ border (px 1)
            , borderStyle solid
            , borderTopColor (rgba 255 255 255 0.1)
            , borderRightColor transparent
            , borderBottomColor (rgba 38 50 56 0.2)
            , borderLeftColor transparent
            ]
        ]


boxShadowX : String -> Mixin
boxShadowX shadow =
    property "box-shadow" shadow


background color =
    property "background" color


zIndex : Int -> Mixin
zIndex i =
    property "z-index" <| toString i



--TODO make conversion based on hex color


contrastColor : Color -> Mixin
contrastColor rgbColor =
    let
        yiq =
            toFloat ((rgbColor.red * 299) + (rgbColor.green * 587) + (rgbColor.blue * 114)) / 1000
    in
        if yiq >= 128 then
            color (hex "000")
        else
            color (hex "fff")
