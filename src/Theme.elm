module Theme exposing (..)

import Html exposing (..)
import Html.Attributes exposing (attribute)

 
type alias ThemeRecord =
    { primaryColor : String
    , accentColor : String
    , themeColor : String
    , appBarColor : String
    , inputBar : String
    , inputField : String
    }

type Theme 
 = BobaFett
 | Default
 | Chill
 | Custom ThemeRecord

setTheme: ThemeRecord -> List (String, String)
setTheme theme =
    [ ( "primary-color", theme.primaryColor )
    , ( "primary-text-color", createContextColor theme.primaryColor)
    , ( "accent-color", theme.accentColor )
    , ( "accent-text-color", createContextColor theme.accentColor)
    , ( "theme-color", theme.themeColor )
    , ( "theme-text-color", createContextColor theme.themeColor)
    , ( "theme-appbar", theme.appBarColor )
    , ( "theme-appbar-text", createContextColor theme.appBarColor)
    , ( "theme-input-bar", theme.inputBar )
    , ( "theme-input-field", theme.inputField )
    , ( "theme-input-field-text", createContextColor theme.inputField)
    ]
    

getTheme : Theme -> Attribute msg
getTheme theme =
 case theme of
    BobaFett ->
        setTheme bobafett |> customCssProperties

    Default ->
        setTheme default |> customCssProperties

    Chill ->
        setTheme chill |> customCssProperties

    Custom themeRecord ->
        setTheme themeRecord |> customCssProperties


default =
    { primaryColor = "#006cb7" 
    , accentColor = "#9ac933"
    , themeColor = "#212121"
    , appBarColor = "#424242"
    , inputBar = "#212121" 
    , inputField = "#303030"
    }

bobafett =
    { primaryColor = "#71262D" 
    , accentColor = "#F3C72A"
    , themeColor = "#A19AA1"
    , appBarColor = "#5E6E63"
    , inputBar = "#5E6E63"
    , inputField = "#123A31"
    }


chill =
    { primaryColor = "#1d2730" 
    , accentColor = "#ec8439" 
    , themeColor = "#0f2d4c"
    , appBarColor = "#424242"
    , inputBar = "#1d2730"
    , inputField = "#303030"
    }


type alias RGB =
    { red : Int
    , green : Int
    , blue : Int
    }


createContextColor hexString = 
    hexToRgb hexString |> rgbToContrastColor 


rgbToContrastColor rgbColor =
    let
        yiq =
            toFloat ((rgbColor.red * 299) + (rgbColor.green * 587) + (rgbColor.blue * 114)) / 1000
    in
    if yiq >= 128 then
        "#000"

    else
        "#fff"


customCssProperties : List ( String, String ) -> Attribute msg
customCssProperties styles =
    let
        css =
            styles
                |> List.foldl
                    (\( prop, val ) acc ->
                        String.append acc ("--" ++ prop ++ ":" ++ val ++ ";\n")
                    )
                    ""
    in
    attribute "style" css



--This is not that robust, but its a start

hexToRgb : String -> RGB
hexToRgb hexString =
    let
        intValue =
            String.replace "#" "" hexString |> fromString
        
    in
        intToRgb intValue


intToRgb : Result String Int -> RGB
intToRgb integer =
    case integer of
        Ok number ->
            let
                blue =
                    modBy 256 number

                red =
                    modBy 256 <| floor (toFloat number / 256 / 256)

                green =
                    modBy 256 <| floor (toFloat number / 256)
            in
            { red = red, green = green, blue = blue }

        Err err ->
            { red = 0, green = 0, blue = 0 }


fromString : String -> Result String Int
fromString str =
    if String.isEmpty str then
        Err "Empty strings are not valid hexadecimal strings."

    else
        let
            result =
                if String.startsWith "-" str then
                    let
                        list =
                            str
                                |> String.toList
                                |> List.tail
                                |> Maybe.withDefault []
                    in
                    fromStringHelp (List.length list - 1) list 0
                        |> Result.map negate

                else
                    fromStringHelp (String.length str - 1) (String.toList str) 0

            formatError err =
                String.join " "
                    [ "\"" ++ str ++ "\""
                    , "is not a valid hexadecimal string because"
                    , err
                    ]
        in
        Result.mapError formatError result


fromStringHelp : Int -> List Char -> Int -> Result String Int
fromStringHelp position chars accumulated =
    case chars of
        [] ->
            Ok accumulated

        char :: rest ->
            case char of
                '0' ->
                    fromStringHelp (position - 1) rest accumulated

                '1' ->
                    fromStringHelp (position - 1) rest (accumulated + (16 ^ position))

                '2' ->
                    fromStringHelp (position - 1) rest (accumulated + (2 * (16 ^ position)))

                '3' ->
                    fromStringHelp (position - 1) rest (accumulated + (3 * (16 ^ position)))

                '4' ->
                    fromStringHelp (position - 1) rest (accumulated + (4 * (16 ^ position)))

                '5' ->
                    fromStringHelp (position - 1) rest (accumulated + (5 * (16 ^ position)))

                '6' ->
                    fromStringHelp (position - 1) rest (accumulated + (6 * (16 ^ position)))

                '7' ->
                    fromStringHelp (position - 1) rest (accumulated + (7 * (16 ^ position)))

                '8' ->
                    fromStringHelp (position - 1) rest (accumulated + (8 * (16 ^ position)))

                '9' ->
                    fromStringHelp (position - 1) rest (accumulated + (9 * (16 ^ position)))

                'a' ->
                    fromStringHelp (position - 1) rest (accumulated + (10 * (16 ^ position)))

                'b' ->
                    fromStringHelp (position - 1) rest (accumulated + (11 * (16 ^ position)))

                'c' ->
                    fromStringHelp (position - 1) rest (accumulated + (12 * (16 ^ position)))

                'd' ->
                    fromStringHelp (position - 1) rest (accumulated + (13 * (16 ^ position)))

                'e' ->
                    fromStringHelp (position - 1) rest (accumulated + (14 * (16 ^ position)))

                'f' ->
                    fromStringHelp (position - 1) rest (accumulated + (15 * (16 ^ position)))

                'A' ->
                    fromStringHelp (position - 1) rest (accumulated + (10 * (16 ^ position)))

                'B' ->
                    fromStringHelp (position - 1) rest (accumulated + (11 * (16 ^ position)))

                'C' ->
                    fromStringHelp (position - 1) rest (accumulated + (12 * (16 ^ position)))

                'D' ->
                    fromStringHelp (position - 1) rest (accumulated + (13 * (16 ^ position)))

                'E' ->
                    fromStringHelp (position - 1) rest (accumulated + (14 * (16 ^ position)))

                'F' ->
                    fromStringHelp (position - 1) rest (accumulated + (15 * (16 ^ position)))

                nonHex ->
                    Err (String.fromChar nonHex ++ " is not a valid hexadecimal character.")