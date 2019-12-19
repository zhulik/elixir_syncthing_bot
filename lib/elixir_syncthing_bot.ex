defmodule ElixirSyncthingBot do
  use Application

  alias ElixirSyncthingBot.Syncthing.Api

  alias ElixirSyncthingBot.Notifiers.FoldersState
  alias ElixirSyncthingBot.Notifiers.NotifierDispatcher

  alias ElixirSyncthingBot.Syncthing.Api.ConfigListener
  alias ElixirSyncthingBot.Syncthing.Api.ConnectionsListener
  alias ElixirSyncthingBot.Syncthing.Api.EventListener

  def start(_type, _args) do
    notifier = System.get_env("NOTIFIER") || "console"
    notifier_options = System.get_env("NOTIFIER_OPTIONS") || ""

    children = [
      {Registry, [keys: :unique, name: Registry.ElixirSyncthingBot]},
      FoldersState,
      NotifierDispatcher.notifier(notifier, notifier_options)
    ]

    servers =
      (System.get_env("SERVERS") || "")
      |> String.trim()
      |> String.split(";")
      |> Enum.map(&String.trim/1)
      |> Enum.filter(fn server -> server != "" end)
      |> Enum.map(&URI.parse/1)
      |> Enum.map(fn uri ->
        Api.client(
          host: "#{uri.scheme}://#{uri.host}:#{uri.port}#{uri.path}",
          token: uri.userinfo
        )
      end)
      |> Enum.map(&server_specs/1)

    {:ok, _} = Logger.add_backend(Sentry.LoggerBackend)

    opts = [strategy: :one_for_one, name: ElixirSyncthingBot.Supervisor]
    Supervisor.start_link(children ++ servers, opts)
  end

  defp server_specs(api) do
    children = [
      {EventListener, api},
      {ConfigListener, api},
      {ConnectionsListener, api}
    ]

    %{
      id: "#{api.host}.supervisor",
      start: {Supervisor, :start_link, [children, [strategy: :one_for_one]]}
    }
  end
end
