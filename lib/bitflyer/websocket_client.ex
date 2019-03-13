defmodule Bitflyer.JsonRPC2 do
  defstruct [:jsonrpc, :method, :params, :result, :id]
end

defmodule Bitflyer.SubscribeParams do
  defstruct [:channel]
end

defmodule Bitflyer.WebsocketClient do
  @url Application.get_env(:bitcoin_data_collector, :bitflyer_lightning_jsonrpc_endpoint)

  use Task

  alias Bitflyer.JsonRPC2
  alias Bitflyer.SubscribeParams

  def start_link(args) do
    Task.start_link(__MODULE__, :run, [args])
  end

  def connect do
    IO.puts "<---------- connect start ---------->"
    Socket.connect @url
  end

  def subscribe({:ok, socket}) do
    IO.puts "<---------- connect OK ---------->"
    IO.inspect socket
    IO.puts "<---------- subscribe send start ---------->"
    jsonrpc2 = %JsonRPC2{jsonrpc: "2.0", method: "subscribe", params: %SubscribeParams{channel: ""}}
  end

  def subscribe({:error, message}) do
    IO.puts "<---------- connect NG ---------->"
    IO.inspect "Error: " <> message
  end

  def run(args) when is_nil(args) do
    connect()
    |> subscribe
  end
end
