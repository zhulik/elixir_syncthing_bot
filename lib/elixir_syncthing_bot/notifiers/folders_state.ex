defmodule ElixirSyncthingBot.Notifiers.FoldersState do
  use ExActor.GenServer, export: __MODULE__

  alias ElixirSyncthingBot.Syncthing.Api.Config

  defstart start_link(_) do
    initial_state(%{})
  end

  defcall add_event(config, event), state: state do
    device_key = %{id: Config.my_id(config), name: Config.my_name(config)}
    folder_key = %{id: event.data.folder, name: Config.folder_name(config, event.data.folder)}

    new_state =
      state
      |> Map.put_new(device_key, %{})
      |> apply_event(device_key, folder_key, event)
      |> cleanup_state

    set_and_reply(new_state, {state != new_state, new_state})
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
