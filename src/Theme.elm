module Theme exposing (bobafett, customCssProperties, defaultTheme, chill, rgbToContrastColor)

import Html exposing (..)
import Html.Attributes exposing (attribute)


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
    , ( "primary-text-color", "#fff" )
    , ( "accent-color", "#F3C72A" )
    , ( "accent-text-color", "#000" )
    , ( "theme-color", "#A19AA1" )
    , ( "theme-text-color", "#fff" )
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
