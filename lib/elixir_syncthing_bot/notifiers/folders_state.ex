defmodule ElixirSyncthingBot.Notifiers.FoldersState do
  use GenServer

  alias ElixirSyncthingBot.Syncthing.Api.Config

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: :folders_state)
  end

  @impl true
  def init(state) do
    {:ok, state}
  end

  def add_event(config, event) do
    GenServer.call(:folders_state, {:add_event, config, event})
  end

  @impl true
  def handle_call({:add_event, config, event}, _from, state) do
    device_key = %{id: Config.my_id(config), name: Config.my_name(config)}
    folder_key = %{id: event.data.folder, name: Config.folder_name(config, event.data.folder)}

    state = Map.put_new(state, device_key, %{})

    {:reply, state, state}
  end
end
