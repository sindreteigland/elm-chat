port module Stylesheets exposing (..)

import Css.File exposing (CssFileStructure, CssCompilerProgram)
import Chat.Css


port files : CssFileStructure -> Cmd msg


fileStructure : CssFileStructure
fileStructure =
    Css.File.toFileStructure
        [ ( "public/chat.css", Css.File.compile [ Chat.Css.css ] ) ]


main : CssCompilerProgram
main =
    Css.File.compiler files fileStructure
