defmodule ElixirSyncthingBot.Syncthing.Api.ConfigListener do
  use GenServer

  alias ElixirSyncthingBot.Syncthing.Api
  alias ElixirSyncthingBot.Syncthing.Api.Config

  @delay 10_000

  defmacrop log(msg) do
    quote do
      require Logger

      Logger.info(unquote(msg) <> " #{__MODULE__} #{var!(state).host}")
    end
  end

  def start_link(server) do
    GenServer.start_link(__MODULE__, server, name: name(server[:host]))
  end

  @impl true
  def init(host: host, token: token) do
    GenServer.cast(self(), :update)

    state = %{
      host: host,
      client: Api.client(host: host, token: token),
      config: {},
      status: {}
    }

    log("Starting...")

    {:ok, state}
  end

  def get(host) do
    GenServer.call(name(host), :get)
  end

  @impl true
  def handle_cast(:update, state) do
    log("Updating config...")
    Process.send_after(self(), :update, @delay)
    config = config(state.client, state.config, state.status)

    {:noreply, Map.merge(state, config)}
  end

  @impl true
  def handle_call(:get, _from, state) do
    {:reply, Map.take(state, [:config, :status]), state}
  end

  @impl true
  def handle_info(:update, state) do
    GenServer.cast(self(), :update)
    {:noreply, state}
  end

  defp config(client, current_config, current_status) do
    case request_config(client, current_config, current_status) do
      [ok: config, ok: status] -> %{config: config, status: status}
      _ -> %Config{config: current_config, status: current_status}
    end
  end

  defp request_config(client, current_config, current_status) do
    [
      fn -> config(client, current_config) end,
      fn -> status(client, current_status) end
    ]
    |> Task.async_stream(fn f -> f.() end, on_timeout: :kill_task)
    |> Enum.to_list()
  end

  defp config(client, current_config) do
    case Api.config(client) do
      {:ok, %{status: 200, body: config}} ->
        config

      {:error, _data} ->
        current_config
    end
  end

  defp status(client, current_status) do
    case Api.status(client) do
      {:ok, %{status: 200, body: status}} ->
        status

      {:error, _data} ->
        current_status
    end
  end

  defp name(host) do
    {:via, Registry, {Registry.ElixirSyncthingBot, "#{host}.config"}}
  end
end
