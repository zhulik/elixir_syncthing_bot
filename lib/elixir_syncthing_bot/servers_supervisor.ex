defmodule ElixirSyncthingBot.ServersSupervisor do
  use DynamicSupervisor

  alias ElixirSyncthingBot.Syncthing.Api.ConfigListener
  alias ElixirSyncthingBot.Syncthing.Api.ConnectionsListener
  alias ElixirSyncthingBot.Syncthing.Api.EventListener

  def start_link(init_arg) do
    DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl true
  def init(_) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def add_server(args) do
    spec = {EventListener, args}
    DynamicSupervisor.start_child(__MODULE__, spec)

    spec = {ConfigListener, args}
    DynamicSupervisor.start_child(__MODULE__, spec)

    spec = {ConnectionsListener, args}
    DynamicSupervisor.start_child(__MODULE__, spec)
  end
end
