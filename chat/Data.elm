module Data exposing (..)

import Json.Encode as JE
import Phoenix.Socket


type ConversatinonType
    = Direct
    | Group
    | Channel


type KeyboardType
    = None
    | EmojiPicker
    | GifPicker


type MessageType
    = Text
    | Emotes
    | Gif
    | Unknown


type Msg
    = SetNewMessage String
    | JoinChannel
    | PhoenixMsg (Phoenix.Socket.Msg Msg)
    | SendMessage
    | ReciveChatMessage JE.Value
    | Keyboard KeyboardType
    | ChatMessagesChanged
    | EmojiClicked String
    | GifClicked String
    | BackSpace
    | ChangeChat Conversation
    | LeftMenuToggle


type alias ChatMessage =
    { userId : String
    , msgType : MessageType
    , body : String
    }


type alias Conversation =
    { conversationId : String
    , conversationType : ConversatinonType
    , users : List User
    , conversationName : String
    , picture : String
    , color : String
    , messages : List ChatMessage
    }


type alias Model =
    { newMessage : NewMessage
    , messages : List ChatMessage
    , conversations : List Conversation
    , phxSocket : Phoenix.Socket.Socket Msg
    , userList : List User
    , currentUser : User
    , keyboard : KeyboardType
    , focusedChat : Conversation
    , leftMenuOpen : Bool
    }


type alias NewMessage =
    { msgType : MessageType
    , message : String
    }


type alias User =
    { userId : String
    , userName : String
    , color : String
    , picture : String
    }



--TODO dummy user for chat, change to real user


disUsr =
    "user3"


conversations : List Conversation
conversations =
    [ { conversationId = "1"
      , conversationType = Direct
      , color = "#D50000"
      , users =
            [ { userId = "user2", userName = "David", color = "#D50000", picture = "486268_1433989646157_full.png" }
            ]
      , conversationName = "David"
      , picture = "486268_1433989646157_full.png"
      , messages = messages
      }
    , { conversationId = "2"
      , conversationType = Direct
      , color = "#25e075"
      , users =
            [ { userId = "user1", userName = "Bob", color = "#25e075", picture = "unnamed.png" }
            ]
      , conversationName = "Bob"
      , picture = "unnamed.png"
      , messages = messages2
      }
    , { conversationId = "3"
      , conversationType = Direct
      , color = "#2196F3"
      , users =
            [ { userId = "user4", userName = "Kim", color = "#2196F3", picture = "0.jpg" }
            ]
      , conversationName = "Jim"
      , picture = "0.jpg"
      , messages = messages3
      }
    , { conversationId = "4"
      , conversationType = Group
      , color = "#673AB7"
      , users = users
      , conversationName = "The Boyz"
      , picture = "0.jpg"
      , messages = messages4
      }
    ]


users : List User
users =
    [ { userId = "user1", userName = "Bob", color = "#25e075", picture = "unnamed.png" }
    , { userId = "user2", userName = "David", color = "#D50000", picture = "486268_1433989646157_full.png" }
    , { userId = "user3", userName = "Jelly kid", color = "#673AB7", picture = "b0ce1e9c577d40ee25fe3aeea4798561.jpg" }
    , { userId = "user4", userName = "Jim", color = "#2196F3", picture = "0.jpg" }
    ]


messages : List ChatMessage
messages =
    [ { userId = "user2", msgType = Text, body = "Hello!" }
    , { userId = "user2", msgType = Text, body = "Lenge siden sist" }
    , { userId = "user2", msgType = Text, body = "Har du noe sand jeg kan låne?" }
    , { userId = "user3", msgType = Text, body = "Waaadup!" }
    , { userId = "user3", msgType = Text, body = "Har 2 poser" }
    ]


messages2 =
    [ { userId = "user3", msgType = Text, body = "Hei Bob" }
    , { userId = "user1", msgType = Text, body = "Hello!" }
    , { userId = "user3", msgType = Text, body = "Kan det fikses?" }
    , { userId = "user1", msgType = Text, body = "Klart det kan!" }
    , { userId = "user3", msgType = Text, body = "Noice!" }
    ]


messages3 =
    [ { userId = "user3", msgType = Text, body = "Hei Jim, Lenge siden" }
    , { userId = "user4", msgType = Text, body = "Hei du" }
    , { userId = "user3", msgType = Text, body = "Har du lyst til å ta en båt tur?" }
    , { userId = "user4", msgType = Text, body = "Nei" }
    , { userId = "user4", msgType = Text, body = "Vi er ikke venner!" }
    ]


messages4 =
    [ { userId = "user1", msgType = Text, body = "Hello!" }
    , { userId = "user2", msgType = Text, body = "Eyyy" }
    , { userId = "user3", msgType = Text, body = "Waaadup!" }
    , { userId = "user4", msgType = Text, body = "Hei 😄" }
    , { userId = "user1", msgType = Text, body = "Er det noe liv?" }
    , { userId = "user4", msgType = Text, body = "Vi bare tester ut denne rå chatten, funker som et fly" }
    , { userId = "user3", msgType = Text, body = "Sykt kult. er den skrevet i JQuery?" }
    , { userId = "user2", msgType = Text, body = "Lol, har du slått deg. Dette er Elm baby!" }
    , { userId = "user3", msgType = Gif, body = "https://media.tenor.com/images/65b3da99d3626f98e84f014f01d62b31/tenor.gif" }
    , { userId = "user4", msgType = Emotes, body = "😂😂😂" }
    , { userId = "user3", msgType = Emotes, body = "👌👌👌👌👌" }
    , { userId = "user4", msgType = Gif, body = "https://media2.giphy.com/media/z1FzPhvrIZXTa/giphy.gif" }
    , { userId = "user2", msgType = Text, body = "hei, Jeg skriver dcenne meldingern fordi ejeg kjører noen tester. hvor mye tekst kan jeg skrive før ting går gale. Altså hvor lang kan teksten være og vil det se bra ut??? dette kan bare gudene vite og vi vil aldri forstå hvordan det henger sammen" }
    ]


gifs =
    [ { prev = "https://media.tenor.com/images/b01f155c74ee62a67c4a372072198f5a/tenor.gif", gif = "https://media.tenor.com/images/9792ea789f6585fcda4222c5ceaf9a8d/tenor.gif" }
    , { prev = "https://media.tenor.com/images/441e6bdcd42a9546d1f77062df007dfa/tenor.gif", gif = "https://media.tenor.com/images/ed8cf447392c5e7e0cc16cbad2a0edce/tenor.gif" }
    , { prev = "https://media.tenor.com/images/9146bdbe7d5570f655b4b4216c9139ce/tenor.gif", gif = "https://media.tenor.com/images/da2c52f4d1cf4141b16d32d6fddbabc9/tenor.gif" }
    , { prev = "https://media.tenor.com/images/589f2efe0f9a9f88f693d4785af604bd/tenor.gif", gif = "https://media.tenor.com/images/6d413af92fe56d674e2deadc52ee7e35/tenor.gif" }
    , { prev = "https://media.tenor.com/images/63d56523f490ff32f2bcd11fe48057a3/tenor.gif", gif = "https://media.tenor.com/images/282e5c33d659a52ab6d3b553b6582640/tenor.gif" }
    , { prev = "https://media.tenor.com/images/32c0d5729123e0a381dab5352bb2b696/tenor.gif", gif = "https://media.tenor.com/images/bb6649204120d95457f75b1331ecbec6/tenor.gif" }
    , { prev = "https://media.tenor.com/images/ee31e7e7b878b76e52ad5d74dec0ddb1/tenor.gif", gif = "https://media.tenor.com/images/af11b46852d943529840397f9ab95cf3/tenor.gif" }
    , { prev = "https://media.tenor.com/images/bf71e703ee2a9b4de8af5c8cff8af74d/tenor.gif", gif = "https://media.tenor.com/images/efd15177767f3c6217338e318751d6b0/tenor.gif" }
    , { prev = "https://media.tenor.com/images/eee25ace52af637d449b81fb1c7452ee/tenor.gif", gif = "https://media.tenor.com/images/c103c6bcdaa5d98f0fee4e747b161c14/tenor.gif" }
    , { prev = "https://media.tenor.com/images/cf6d2f93405d054907debe7d726feeb3/tenor.gif", gif = "https://media.tenor.com/images/5305cf820f1d3665f5281ce473b92313/tenor.gif" }
    ]
