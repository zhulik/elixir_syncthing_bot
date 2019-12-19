defmodule ElixirSyncthingBot.ServerSupervisor do
  use Supervisor

  alias ElixirSyncthingBot.Syncthing.Api.ConfigListener
  alias ElixirSyncthingBot.Syncthing.Api.ConnectionsListener
  alias ElixirSyncthingBot.Syncthing.Api.EventListener

  def start_link(api) do
    Supervisor.start_link(__MODULE__, api)
  end

  def init(api) do
    children = [
      {EventListener, api},
      {ConfigListener, api},
      {ConnectionsListener, api}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
