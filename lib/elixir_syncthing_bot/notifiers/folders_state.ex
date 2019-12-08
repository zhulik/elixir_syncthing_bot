defmodule ElixirSyncthingBot.Notifiers.FoldersState do
  use GenServer

  alias ElixirSyncthingBot.Syncthing.Api.Config

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{},
      name: {:via, Registry, {Registry.ElixirSyncthingBot, :folders_state}}
    )
  end

  @impl true
  def init(state) do
    {:ok, state}
  end

  def add_event(config, event) do
    GenServer.call(
      {:via, Registry, {Registry.ElixirSyncthingBot, :folders_state}},
      {:add_event, config, event}
    )
  end

  @impl true
  def handle_call({:add_event, config, event}, _from, state) do
    device_key = %{id: Config.my_id(config), name: Config.my_name(config)}
    folder_key = %{id: event.data.folder, name: Config.folder_name(config, event.data.folder)}

    new_state =
      state
      |> Map.put_new(device_key, %{})
      |> apply_event(device_key, folder_key, event)
      |> cleanup_state

    {:reply, {state != new_state, new_state}, new_state}
  end

  defp apply_event(state, device_key, folder_key, %{data: %{summary: %{state: "idle"}}}) do
    pop_in(state, [device_key, folder_key]) |> elem(1)
  end

  defp apply_event(
         state,
         device_key,
         folder_key,
         %{data: %{summary: %{state: "syncing"}}} = event
       ) do
    if state[device_key][folder_key] do
      put_in(state, [device_key, folder_key], %{
        state[device_key][folder_key]
        | current: event.data.summary.inSyncBytes,
          total: event.data.summary.globalBytes
      })
    else
      put_in(state, [device_key, folder_key], %{
        start: event.data.summary.inSyncBytes,
        current: event.data.summary.inSyncBytes,
        total: event.data.summary.globalBytes
      })
    end
  end

  defp apply_event(state, _device_key, _folder_key, _event) do
    state
  end

  defp cleanup_state(state) do
    :maps.filter(fn _k, v -> v != %{} end, state)
  end
end
