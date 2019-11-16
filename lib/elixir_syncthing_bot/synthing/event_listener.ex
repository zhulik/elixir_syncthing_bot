defmodule ElixirSyncthingBot.Syncthing.Api.EventListener do
  use GenServer

  alias ElixirSyncthingBot.Notifiers.NotifierDispatcher
  alias ElixirSyncthingBot.Syncthing.Api
  alias ElixirSyncthingBot.Syncthing.Api.ConfigListener

  defmacrop log(msg) do
    quote do
      require Logger

      Logger.info(unquote(msg) <> " #{__MODULE__} #{var!(state).host}")
    end
  end

  def start_link(server) do
    GenServer.start_link(__MODULE__, server,
      name: {:via, Registry, {Registry.ElixirSyncthingBot, "#{server[:host]}.events"}}
    )
  end

  @impl true
  def init(host: host, token: token) do
    send(self(), :run)

    client = Api.client(host: host, token: token)

    state = %{
      host: host,
      client: client,
      since: nil
    }

    log("Starting...")

    {:ok, state, {:continue, :recover_state}}
  end

  @impl true
  def handle_continue(:recover_state, state) do
    {:ok, events} = Api.events(state.client)
    {:noreply, %{state | since: Enum.at(events, -1).id}}
  end

  @impl true
  def handle_info(:run, state) do
    log("Requesting events...")

    state =
      Api.events(state.client, state.since)
      |> process_events(state)

    send(self(), :run)
    {:noreply, state}
  end

  defp process_events({:ok, events}, state) do
    log("Got #{Enum.count(events)} events")

    config = ConfigListener.get(state.host)

    events
    |> Enum.map(fn event -> [config: config, event: event] end)
    |> NotifierDispatcher.process!()

    %{state | since: Enum.at(events, -1).id}
  end

  defp process_events({:error, :econnrefused}, state) do
    Process.sleep(10_000)
    state
  end

  defp process_events({:error, _}, state) do
    state
  end
end
