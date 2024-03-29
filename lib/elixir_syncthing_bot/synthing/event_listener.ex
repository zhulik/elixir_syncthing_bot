defmodule ElixirSyncthingBot.Syncthing.Api.EventListener do
  use GenServer

  alias ElixirSyncthingBot.Notifiers.NotifierDispatcher
  alias ElixirSyncthingBot.Syncthing.Api
  alias ElixirSyncthingBot.Syncthing.Api.ConfigListener
  alias ElixirSyncthingBot.Syncthing.Api.ConnectionsListener

  defmacrop log(msg) do
    quote do
      require Logger

      Logger.info(unquote(msg) <> " #{__MODULE__} #{var!(state).api.host}")
    end
  end

  def start_link(api) do
    GenServer.start_link(__MODULE__, api,
      name: {:via, Registry, {Registry.ElixirSyncthingBot, "#{api.host}.events"}}
    )
  end

  @impl true
  def init(api) do
    state = %{
      api: api,
      since: nil
    }

    log("Starting...")

    {:ok, state, {:continue, :recover_state}}
  end

  @impl true
  def handle_continue(:recover_state, state) do
    case Api.events(state.api) do
      {:ok, events} ->
        send(self(), :run)
        {:noreply, %{state | since: Enum.at(events, -1).id}}

      {:error, _} ->
        send(self(), :run)
        {:noreply, state}
    end
  end

  @impl true
  def handle_info(:run, state) do
    log("Requesting events...")

    Task.async(fn ->
      {:updated, Api.events(state.api, state.since)}
    end)

    {:noreply, state}
  end

  @impl true
  def handle_info({_task, {:updated, result}}, state) do
    state =
      result
      |> process_events(state)

    send(self(), :run)
    {:noreply, state}
  end

  @impl true
  def handle_info({:DOWN, _, _, _, _}, state) do
    {:noreply, state}
  end

  defp process_events({:ok, events}, state) do
    log("Got #{Enum.count(events)} events")

    config = ConfigListener.get(state.api.host)
    rates = ConnectionsListener.rates(state.api.host)

    events
    |> Enum.map(fn event -> [config: config, event: event, rates: rates] end)
    |> NotifierDispatcher.process!()

    %{state | since: Enum.at(events, -1).id}
  end

  defp process_events({:error, _}, state) do
    Process.sleep(10_000)
    state
  end
end
