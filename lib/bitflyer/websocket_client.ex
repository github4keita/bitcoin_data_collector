defmodule Bitflyer.Subscribe do
  defstruct [:method, :params]
end

defmodule Bitflyer.SubscribeParams do
  defstruct [:channel]
end

defmodule Bitflyer.WebsocketClient do
  @url Application.get_env(:bitcoin_data_collector, :bitflyer_lightning_jsonrpc_endpoint)

  use Task, restart: :transient

  alias Bitflyer.Subscribe
  alias Bitflyer.SubscribeParams

  def start_link(args) do
    Task.start_link(__MODULE__, :run, [args])
  end

  def response_match({:ok, data}) do
    IO.puts "<---------- response OK ---------->"
    data
  end

  def response_match({:error, message}, socket \\ nil) do
    IO.puts "<---------- response NG ---------->"
    IO.puts "Error: " <> message
    close(socket)
    raise message
  end

  def response_match(:ok, _) do
    IO.puts "<---------- response OK ---------->"
  end

  def opcode_match({:close, _, _}, socket) do
    IO.puts "<---------- opcode: close ---------->"
    close(socket)
    nil
  end

  def opcode_match({:ping, _}, socket) do
    IO.puts "<---------- opcode: ping ---------->"
    send_pong(socket)
    nil
  end

  def opcode_match({:text, data}, _) do
    IO.puts "<---------- opcode: text ---------->"
    data
  end

  def connect do
    IO.puts "<---------- connect start ---------->"
    Socket.connect(@url)
    |> response_match
  end

  def close(socket) when is_nil(socket), do: nil

  def close(socket) do
    IO.puts "<---------- connection close ---------->"
    Socket.Web.close socket
  end

  def send_text(data, socket) do
    IO.puts "<---------- send text ---------->"
    IO.puts data
    Socket.Web.send socket, {:text, data}
  end

  def send_pong(socket) do
    IO.puts "<---------- send pong ---------->"
    Socket.Web.send socket, {:pong, ""}
  end

  def recv(socket) do
    Socket.Web.recv(socket)
    |> response_match
    |> opcode_match(socket)
    |> IO.inspect

    recv(socket)
  end

  def subscribe(socket, channel) do
    IO.puts "<---------- subscribe start ---------->"
    jsonrpc2 = %Subscribe{method: "subscribe", params: %SubscribeParams{channel: channel}}

    Poison.encode!(jsonrpc2)
    |> send_text(socket)
    |> response_match(socket)

    socket
  end

  def run(args) do
    connect()
    |> subscribe(args[:channel])
    |> recv
  end
end
