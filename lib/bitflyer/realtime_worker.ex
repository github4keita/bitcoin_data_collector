defmodule Bitflyer.RealtimeWorker do
  use GenServer

  def init(start_args) do
    {:ok, start_args}
  end

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end
end
