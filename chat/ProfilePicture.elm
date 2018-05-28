module ProfilePicture exposing (..)

import Html exposing (..)
import Html.Attributes exposing (class, id, placeholder, src, style, value)
import Html.CssHelpers


-- My Stuff

import Data exposing (..)
import Chat.Css as ChatCss


{ id, class, classList } =
    Html.CssHelpers.withNamespace "rainchat"


profilePicture : String -> String -> Html Msg
profilePicture color picture =
    img [ class [ ChatCss.ProfilePicture ], src picture, style [ ( "border-color", color ) ] ] []
