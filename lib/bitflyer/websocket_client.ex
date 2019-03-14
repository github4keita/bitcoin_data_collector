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

  def connect do
    IO.puts "<---------- connect start ---------->"
    Socket.connect @url
  end

  def check_result(:ok, name) do
    IO.puts "<---------- #{name} OK ---------->"
  end

  def check_result({:ok, result}, name) do
    IO.puts "<---------- #{name} OK ---------->"
    result
  end

  def check_result({:error, message}, name) do
    IO.puts "<---------- #{name} NG ---------->"
    IO.puts "Error: " <> message
    raise message
  end

  def send_text(data, socket) do
    Socket.Web.send(socket, {:text, data})
  end

  def recv(socket) do
    Socket.Web.recv(socket)
    |> IO.inspect

    recv(socket)
  end

  def subscribe(socket, channel) do
    IO.puts "<---------- subscribe send start ---------->"
    jsonrpc2 = %Subscribe{method: "subscribe", params: %SubscribeParams{channel: channel}}

    Poison.encode!(jsonrpc2)
    |> send_text(socket)
    |> check_result("send")

    socket
  end

  def run(args) do
    connect()
    |> check_result("connect")
    |> subscribe(args[:channel])
    |> recv
    # recv(socket)
  end
end
