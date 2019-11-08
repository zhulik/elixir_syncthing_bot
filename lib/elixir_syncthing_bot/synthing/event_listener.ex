defmodule ElixirSyncthingBot.Syncthing.Api.EventListener do
  use GenServer

  alias ElixirSyncthingBot.Notifiers.Console, as: Console
  alias ElixirSyncthingBot.Syncthing.Api, as: Api

  defmacrop log(msg) do
    quote do
      require Logger

      Logger.info(unquote(msg) <> " #{__MODULE__} #{var!(state).host}")
    end
  end

  def start_link(default) do
    GenServer.start_link(__MODULE__, default)
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
        {:ok, %Tesla.Env{status: 200, body: events}} ->
          log("Got #{Enum.count(events)} events")
          Console.process!(events)
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
