module Theme exposing (RGB, bobafett, chill, customCssProperties, defaultTheme, fromString, fromStringHelp, hexToRgb, intToRgb, rgbToContrastColor)

import Html exposing (..)
import Html.Attributes exposing (attribute)
import Regex


defaultTheme =
    [ ( "primary-color", "#006cb7" )
    , ( "primary-text-color", "#fff" )
    , ( "accent-color", "#9ac933" )
    , ( "accent-text-color", "#000" )
    , ( "theme-color", "#212121" )
    , ( "theme-text-color", "#fff" )
    , ( "theme-appbar", "#424242" )
    , ( "theme-appbar-text", "#fff" )
    , ( "theme-input-bar", "#212121" )
    , ( "theme-input-field", "#303030" )
    , ( "theme-input-field-text", "#fff" )
    ]


bobafett =
    [ ( "primary-color", "#71262D" )
    , ( "primary-text-color", createContextColor "71262D" )
    , ( "accent-color", "#F3C72A" )
    , ( "accent-text-color", "#000" )
    , ( "theme-color", "#A19AA1" )
    , ( "theme-text-color", createContextColor "#A19AA1" )
    , ( "theme-appbar", "#5E6E63" )
    , ( "theme-appbar-text", "#fff" )
    , ( "theme-input-bar", "#5E6E63" )
    , ( "theme-input-field", "#123A31" )
    , ( "theme-input-field-text", "#fff" )
    ]


chill =
    [ ( "primary-color", "#1d2730" )
    , ( "primary-text-color", "#fff" )
    , ( "accent-color", "#ec8439" )
    , ( "accent-text-color", "#000" )
    , ( "theme-color", "#0f2d4c" )
    , ( "theme-text-color", "#fff" )
    , ( "theme-appbar", "#424242" )
    , ( "theme-appbar-text", "#fff" )
    , ( "theme-input-bar", "#1d2730" )
    , ( "theme-input-field", "#303030" )
    , ( "theme-input-field-text", "#fff" )
    ]


type alias RGB =
    { red : Int
    , green : Int
    , blue : Int
    }


createContextColor hexString = 
    hexToRgb hexString |> rgbToContrastColor 


rgbToContrastColor rgbColor =
    --Not in use yet, but would be nice to automate text coloring based on background
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
            -- NOTE: It's important to have this call `fromStringHelp` directly.
            -- Previously this called a helper function, but that meant this
            -- was not tail-call optimized; it did not compile to a `while` loop
            -- the way it does now. See 240c3d5aa4f97463b924728935d2989621e9fd6b
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
