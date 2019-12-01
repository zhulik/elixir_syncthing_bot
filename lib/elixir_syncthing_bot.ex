defmodule ElixirSyncthingBot do
  use Application

  alias ElixirSyncthingBot.Notifiers.FoldersState
  alias ElixirSyncthingBot.Notifiers.NotifierDispatcher

  alias ElixirSyncthingBot.ServersSupervisor

  def start(_type, _args) do
    notifier = System.get_env("NOTIFIER") || "console"
    notifier_options = System.get_env("NOTIFIER_OPTIONS") || ""

    children = [
      {Registry, [keys: :unique, name: Registry.ElixirSyncthingBot]},
      ServersSupervisor,
      FoldersState,
      NotifierDispatcher.notifier(notifier, notifier_options)
    ]

    opts = [strategy: :one_for_one, name: ElixirSyncthingBot.Supervisor]

    res = Supervisor.start_link(children, opts)

    (System.get_env("SERVERS") || "")
    |> String.trim()
    |> String.split(";")
    |> Enum.map(&String.trim/1)
    |> Enum.filter(fn server -> server != "" end)
    |> Enum.map(&URI.parse/1)
    |> Enum.map(fn uri ->
      [host: "#{uri.scheme}://#{uri.host}:#{uri.port}/#{uri.query}", token: uri.userinfo]
    end)
    |> Enum.each(&ServersSupervisor.add_server/1)

    {:ok, _} = Logger.add_backend(Sentry.LoggerBackend)

    res
  end
end
