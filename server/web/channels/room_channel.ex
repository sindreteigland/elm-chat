defmodule Server.RoomChannel do
  use Server.Web, :channel

  def join("room:lobby", message, socket) do
    Process.flag(:trap_exit, true)
    send(self(), {:after_join, message})
    {:ok, socket}
  end

  def join("room:" <> _something_else, _msg, _socket) do
    {:error, %{reason: "can't do this"}}
  end

  def handle_info({:after_join, msg}, socket) do
    broadcast! socket, "user:entered", %{user: msg["user"]}
    push socket, "join", %{status: "connected"}
    {:noreply, socket}
  end

  def terminate(_reason, _socket) do
    :ok
  end

  def handle_in("new:msg", msg, socket) do
    broadcast! socket, "new:msg", %{user: msg["user"], messageType: msg["messageType"], body: msg["body"]}
    {:reply, {:ok, %{messageType: msg["messageType"], msg: msg["body"]}}, assign(socket, :user, msg["user"])}
  end
end
