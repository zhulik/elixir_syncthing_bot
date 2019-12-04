defmodule ElixirSyncthingBot.Syncthing.Api.ConnectionsListener do
  use GenServer

  alias ElixirSyncthingBot.Syncthing.Api
  alias ElixirSyncthingBot.Syncthing.Api.Connections

  @delay 3_000

  defmacrop log(msg) do
    quote do
      require Logger

      Logger.info(unquote(msg) <> " #{__MODULE__} #{var!(state).api.host}")
    end
  end

  def rates(host) do
    GenServer.call(name(host), :rates)
  end

  def start_link(server) do
    GenServer.start_link(__MODULE__, server, name: name(server[:host]))
  end

  @impl true
  def init(host: host, token: token) do
    api = Api.client(host: host, token: token)

    state = %{
      api: api,
      connections: nil,
      rates: nil
    }

    log("Starting...")

    Process.send_after(self(), :update, @delay)

    {:ok, state, {:continue, :recover_state}}
  end

  @impl true
  def handle_continue(:recover_state, state) do
    connections = %Connections{
      total: request_connections!(state.api),
      timestamp: timestamp()
    }

    {:noreply,
     %{state | connections: connections, rates: Connections.rates(connections, connections)}}
  end

  @impl true
  def handle_info(:update, state) do
    log("Updating config...")

    connections = %Connections{
      total: request_connections!(state.api),
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
  def handle_call(:rates, _from, state) do
    {:reply, state.rates, state}
  end

  defp name(host) do
    {:via, Registry, {Registry.ElixirSyncthingBot, "#{host}.connections"}}
  end

  defp request_connections!(api) do
    {:ok, connections} = Api.connections(api)
    connections.total
  end

  defp timestamp do
    :os.system_time(:milli_seconds)
  end
end
