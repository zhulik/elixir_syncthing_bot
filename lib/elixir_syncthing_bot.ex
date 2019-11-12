defmodule ElixirSyncthingBot do
  use Application

  alias ElixirSyncthingBot.Notifiers.FoldersState
  alias ElixirSyncthingBot.Notifiers.Notifier

  alias ElixirSyncthingBot.Syncthing.Api.ConfigListener
  alias ElixirSyncthingBot.Syncthing.Api.EventListener

  def start(_type, _args) do
    [notifier: notifier, notifier_options: notifier_options] =
      Application.get_env(:elixir_syncthing_bot, :notifier)

    children = [
      {Registry, [keys: :unique, name: Registry.ElixirSyncthingBot]},
      FoldersState,
      Notifier.notifier(notifier, notifier_options)
    ]

    [servers: servers] = Application.get_env(:elixir_syncthing_bot, :syncthing, :servers)

    servers =
      servers
      |> String.split(";")
      |> Enum.map(&URI.parse/1)
      |> Enum.map(fn uri ->
        [host: "#{uri.scheme}://#{uri.host}:#{uri.port}/#{uri.query}", token: uri.userinfo]
      end)
      |> Enum.flat_map(fn server ->
        [{ConfigListener, server}, {EventListener, server}]
      end)

    opts = [strategy: :one_for_one, name: ElixirSyncthingBot.Supervisor]

    Supervisor.start_link(children ++ servers, opts)
  end
end
