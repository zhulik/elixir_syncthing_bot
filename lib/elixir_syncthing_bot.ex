defmodule ElixirSyncthingBot do
  use Application

  alias ElixirSyncthingBot.Notifiers.FoldersState
  alias ElixirSyncthingBot.Notifiers.Notifier

  alias ElixirSyncthingBot.ServersSupervisor

  def start(_type, _args) do
    [notifier: notifier, notifier_options: notifier_options] =
      Application.get_env(:elixir_syncthing_bot, :notifier)

    children = [
      {Registry, [keys: :unique, name: Registry.ElixirSyncthingBot]},
      ServersSupervisor,
      FoldersState,
      Notifier.notifier(notifier, notifier_options)
    ]

    opts = [strategy: :one_for_one, name: ElixirSyncthingBot.Supervisor]

    res = Supervisor.start_link(children, opts)

    [servers: servers] = Application.get_env(:elixir_syncthing_bot, :syncthing, :servers)

    servers
    |> String.trim()
    |> String.split(";")
    |> Enum.map(&String.trim/1)
    |> Enum.map(&URI.parse/1)
    |> Enum.map(fn uri ->
      [host: "#{uri.scheme}://#{uri.host}:#{uri.port}/#{uri.query}", token: uri.userinfo]
    end)
    |> Enum.each(&ServersSupervisor.add_server/1)

    res
  end
end
