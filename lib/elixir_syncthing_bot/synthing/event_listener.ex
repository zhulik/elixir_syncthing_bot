defmodule ElixirSyncthingBot.Syncthing.Api.EventListener do
  use GenServer

  alias ElixirSyncthingBot.Notifiers.Notifier, as: Notifier
  alias ElixirSyncthingBot.Syncthing.Api, as: Api
  alias ElixirSyncthingBot.Syncthing.Api.ConfigListener, as: ConfigListener

  defmacrop log(msg) do
    quote do
      require Logger

      Logger.info(unquote(msg) <> " #{__MODULE__} #{var!(state).host}")
    end
  end

  def start_link(server) do
    GenServer.start_link(__MODULE__, server,
      name: {:via, Registry, {Registry.Servers, "#{server[:host]}.events"}}
    )
  end

  @impl true
  def init(host: host, token: token) do
    GenServer.cast(self(), :run)

    state = %{
      host: host,
      client: Api.client(host: host, token: token),
      since: nil
    }

    log("Starting...")

    {:ok, state}
  end

  @impl true
  def handle_cast(:run, state) do
    log("Requesting events...")

    state =
      case Api.events(state.client, state.since) do
        {:ok, %{status: 200, body: events}} ->
          log("Got #{Enum.count(events)} events")

          config =
            ConfigListener.get({:via, Registry, {Registry.Servers, "#{state.host}.config"}})

          Notifier.process!(events)
          %{state | since: Enum.at(events, -1).id}

        {:error, :timeout} ->
          state

        {:error, :econnrefused} ->
          :timer.sleep(10_000)
          state

        {:error, data} ->
          state
      end

    GenServer.cast(self(), :run)
    {:noreply, state}
  end
end
