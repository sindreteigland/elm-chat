module Main exposing (Model, Msg(..), init, initialModel, main, update, view)

import Browser
import Browser.Dom as Dom
import Chat
import Data exposing (..)
import Html exposing (..)
import Html.Attributes exposing (class, id)
import Json.Decode.Extra exposing (..)
import Json.Encode as JE
import Task exposing (..)



-- MODEL


type alias Model =
    { chat : Chat.Model
    }


initialModel : Model
initialModel =
    { chat = Chat.init -- Send settings. Maybe class name and stuff like that
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( initialModel, Cmd.none )


type Msg
    = ChatMessage Chat.Msg



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ChatMessage subMsg ->
            let
                ( newChat, newCmd ) =
                    Chat.update subMsg model.chat
            in
            ( { model | chat = newChat }, Cmd.map ChatMessage newCmd )



-- VIEW


view : Model -> Browser.Document Msg
view model =
    { title = "Chat"
    , body =
        [ div [ id "main-container" ]
            [ Chat.view model.chat |> Html.map ChatMessage
            ]
        ]
    }



-- MAIN


main =
    Browser.document
        { init = init
        , update = update
        , view = view
        , subscriptions = \_ -> Sub.none
        }
