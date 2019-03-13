defmodule Bitflyer.JsonRPC2 do
  defstruct [:jsonrpc, :method, :params, :result, :id]
end

defmodule Bitflyer.SubscribeParams do
  defstruct [:channel]
end

defmodule Bitflyer.WebsocketClient do
  @url Application.get_env(:bitcoin_data_collector, :bitflyer_lightning_jsonrpc_endpoint)

  use Task, restart: :permanent

  alias Bitflyer.JsonRPC2
  alias Bitflyer.SubscribeParams

  def start_link(args) do
    Task.start_link(__MODULE__, :run, [args])
  end

  def connect do
    IO.puts "<---------- connect start ---------->"
    Socket.connect @url
  end

  def subscribe({:ok, socket}, channel) do
    IO.puts "<---------- connect OK ---------->"
    IO.inspect socket
    IO.puts "<---------- subscribe send start ---------->"
    jsonrpc2 = %JsonRPC2{jsonrpc: "2.0", method: "subscribe", params: %SubscribeParams{channel: channel}}

    Poison.encode!(jsonrpc2)
    |> IO.inspect

    Socket.Web.close socket
  end

  def subscribe({:error, message}, _) do
    IO.puts "<---------- connect NG ---------->"
    IO.inspect "Error: " <> message
    raise message
  end

  def run(args) do
    connect()
    |> subscribe(args[:channel])
  end
end
