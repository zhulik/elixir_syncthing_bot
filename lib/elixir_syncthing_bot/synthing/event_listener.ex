defmodule ElixirSyncthingBot.Syncthing.Api.EventListener do
  use GenServer

  require Logger

  def start_link(default) do
    GenServer.start_link(__MODULE__, default)
  end

  @impl true
  def init(host: host, token: token) do
    GenServer.cast(self(), :run)

    {:ok,
     %{
       client: ElixirSyncthingBot.Syncthing.Api.client(host: host, token: token),
       since: nil
     }}
  end

  @impl true
  def handle_cast(:run, state) do
    Logger.info("Requesting events...")

    state =
      case ElixirSyncthingBot.Syncthing.Api.events(state.client, state.since) do
        {:ok, %Tesla.Env{status: 200, body: events}} ->
          Logger.info("Got #{Enum.count(events)} events")
          %{state | since: Enum.at(events, -1).id}

        {:error, :timeout} ->
          state
        {:error, data} ->
          state
      end

    GenServer.cast(self(), :run)
    {:noreply, state}
  end
end
