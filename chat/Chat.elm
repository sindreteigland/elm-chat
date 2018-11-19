{-- This will be the chat module. Use it in Main. Once it works as a standalone module, copy paste to Lykehjulet
 Needs to export at least: view, update and Msg.
 In main:

 type Msg
 = ChatMessage Chat.Msg

update msg model =
ChatMessage subMsg ->
 let
     (newChat, newCmd) =
        Chat.update subMsg model.chat
 in
     ({ model  | chat = newModel}, Cmd.map ChatMessage newCmd) --may not directly compile

view model =
  Chat.view model.chat
--}


type alias Model = 0

type Msg = Noop

view : Model -> Html Msg
view model =
    div [ style "display" "flex", style "width" "100%", style "justify-content" "center" ]
        [ mainView model
        ]

    