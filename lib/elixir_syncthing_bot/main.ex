defmodule ElixirSyncthingBot.Main do
  use ExCLI.DSL, escript: true

  alias ElixirSyncthingBot.Notifiers.Notifier, as: Notifier
  alias ElixirSyncthingBot.Syncthing.Api.ConfigListener, as: ConfigListener
  alias ElixirSyncthingBot.Syncthing.Api.EventListener, as: EventListener

  name("elixir_syncthing_bot")

  option(:verbose, aliases: [:v])

  command :run do
    description("Runs the bot")

    option(:servers, help: "A list of servers", type: :string, required: true, aliases: [:s])

    option(:notifier,
      help: "Notifier, supported: console, telegram",
      type: :string,
      default: :console,
      aliases: [:n]
    )

    option(:notifier_options, help: "Notifier options", type: :string, default: "", aliases: [:o])
  end

  def __run__(:run, %{servers: servers, notifier: notifier, notifier_options: notifier_options}) do
    children = [
      {Registry, [keys: :unique, name: Registry.Servers]},
      Notifier.notifier(notifier, notifier_options)
    ]

    servers =
      servers
      |> String.split(";")
      |> Enum.map(&URI.parse/1)
      |> Enum.map(fn uri ->
        [host: "#{uri.scheme}://#{uri.host}:#{uri.port}/#{uri.query}", token: uri.userinfo]
      end)

    children =
      children ++
        Enum.flat_map(servers, fn server ->
          [{EventListener, server}, {ConfigListener, server}]
        end)

    opts = [strategy: :one_for_one, name: ElixirSyncthingBot.Supervisor]
    Supervisor.start_link(children, opts)
    Process.sleep(:infinity)
  end
end
