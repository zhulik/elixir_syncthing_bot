defmodule ElixirSyncthingBot.Syncthing.Api.ConfigListener do
  use GenServer

  alias ElixirSyncthingBot.Syncthing.Api
  alias ElixirSyncthingBot.Syncthing.Api.Config

  @delay 10_000

  defmacrop log(msg) do
    quote do
      require Logger

      Logger.info(unquote(msg) <> " #{__MODULE__} #{var!(state).api.host}")
    end
  end

  def get(host) do
    GenServer.call(name(host), :get)
  end

  def start_link(api) do
    GenServer.start_link(__MODULE__, api, name: name(api.host))
  end

  @impl true
  def init(api) do
    state = %{
      api: api,
      config: nil,
      status: nil
    }

    log("Starting...")

    Process.send_after(self(), :update, @delay)

    {:ok, state, {:continue, :recover_state}}
  end

  @impl true
  def handle_continue(:recover_state, state) do
    [ok: config, ok: status] = request_config!(state.api)

    {:noreply, %{state | config: config, status: status}}
  end

  @impl true
  def handle_call(:get, _from, state) do
    {:reply, Map.take(state, [:config, :status]), state}
  end

  @impl true
  def handle_info(:update, state) do
    log("Updating config...")
    config = config(state.api, state.config, state.status)
    Process.send_after(self(), :update, @delay)

    {:noreply, Map.merge(state, config)}
  end

  defp config(api, current_config, current_status) do
    case request_config(api, current_config, current_status) do
      [ok: config, ok: status] -> %{config: config, status: status}
      _ -> %Config{config: current_config, status: current_status}
    end
  end

  defp request_config(api, current_config, current_status) do
    [
      fn -> config(api, current_config) end,
      fn -> status(api, current_status) end
    ]
    |> Task.async_stream(fn f -> f.() end, on_timeout: :kill_task)
    |> Enum.to_list()
  end

  defp request_config!(api) do
    [
      fn ->
        case Api.config(api) do
          {:ok, config} -> config
          {:error, _} -> nil
        end
      end,
      fn ->
        case Api.status(api) do
          {:ok, status} -> status
          {:error, _} -> nil
        end
      end
    ]
    |> Task.async_stream(fn f -> f.() end)
    |> Enum.to_list()
  end

  defp config(api, current_config) do
    case Api.config(api) do
      {:ok, config} ->
        config

      {:error, _data} ->
        current_config
    end
  end

  defp status(api, current_status) do
    case Api.status(api) do
      {:ok, status} ->
        status

      {:error, _data} ->
        current_status
    end
  end

  defp name(host) do
    {:via, Registry, {Registry.ElixirSyncthingBot, "#{host}.config"}}
  end
end
