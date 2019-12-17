defmodule ElixirSyncthingBot.Syncthing.Api.ConnectionsListener do
  use GenServer

  alias ElixirSyncthingBot.Syncthing.Api
  alias ElixirSyncthingBot.Syncthing.Api.Connections

  @delay 3_000
  @default_total %{inBytesTotal: 0, outBytesTotal: 0}
  @default_rates %{in_rate: 0, out_rate: 0}

  defmacrop log(msg) do
    quote do
      require Logger

      Logger.info(unquote(msg) <> " #{__MODULE__} #{var!(state).api.host}")
    end
  end

  def rates(host) do
    GenServer.call(name(host), :rates)
  end

  def start_link(api) do
    GenServer.start_link(__MODULE__, api, name: name(api.host))
  end

  @impl true
  def init(api) do
    state = %{
      api: api,
      connections: %Connections{
        total: @default_total,
        timestamp: timestamp()
      },
      rates: @default_rates
    }

    log("Starting...")

    Process.send_after(self(), :update, @delay)

    {:ok, state}
  end

  @impl true
  def handle_info(:update, state) do
    log("Updating config...")

    Task.async(fn ->
      {:updated, request_connections(state.api)}
    end)

    {:noreply, state}
  end

  @impl true
  def handle_info({_task, {:updated, total}}, state) do
    connections = %Connections{
      total: total,
      timestamp: timestamp()
    }

    Process.send_after(self(), :update, @delay)

    {:noreply,
     %{
       state
       | connections: connections,
         rates: Connections.rates(state.connections, connections)
     }}
  end

  @impl true
  def handle_info({:DOWN, _, _, _, _}, state) do
    {:noreply, state}
  end

  @impl true
  def handle_call(:rates, _from, state) do
    {:reply, state.rates, state}
  end

  defp name(host) do
    {:via, Registry, {Registry.ElixirSyncthingBot, "#{host}.connections"}}
  end

  defp request_connections(api) do
    case Api.connections(api) do
      {:ok, connections} -> connections.total
      {:error, _} -> @default_total
    end
  end

  defp timestamp do
    :os.system_time(:milli_seconds)
  end
end
