defmodule Server.ChatController do
    use Server.Web, :controller

    def index(conn, _params) do
      render conn, "lobby.html"
    end

end
