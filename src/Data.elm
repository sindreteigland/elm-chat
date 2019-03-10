module Data exposing (..)

type MessageType
    = Text
    | Emotes
    | Gif
    | Unknown

type alias ChatMessage =
    { userId : String
    , msgType : MessageType
    , body : String
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


users : List User
users =
    [ { userId = "user1", userName = "Bob", color = "#25e075", picture = "./public/images/unnamed.png" }
    , { userId = "user2", userName = "David", color = "#D50000", picture = "./public/images/486268_1433989646157_full.png" }
    , { userId = "user3", userName = "Jelly kid", color = "#673AB7", picture = "./public/images/b0ce1e9c577d40ee25fe3aeea4798561.jpg" }
    , { userId = "user4", userName = "Jim", color = "#2196F3", picture = "./public/images/0.jpg" }
    ]

messages4 =
    [ { userId = "user2", msgType = Text, body = "Eyyy" }
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


