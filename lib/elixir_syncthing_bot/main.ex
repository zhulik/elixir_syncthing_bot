defmodule ElixirSyncthingBot.Main do
  use ExCLI.DSL, escript: true

  alias ElixirSyncthingBot.Notifiers.Notifier, as: Notifier
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
    servers =
      servers
      |> String.split(";")
      |> Enum.map(&URI.parse/1)
      |> Enum.map(fn uri ->
        [host: "#{uri.scheme}://#{uri.host}:#{uri.port}/#{uri.query}", token: uri.userinfo]
      end)

    children =
      servers
      |> Enum.map(fn server -> {EventListener, server} end)

    children = children ++ [Notifier.notifier(notifier)]

    opts = [strategy: :one_for_one, name: ElixirSyncthingBot.Supervisor]
    Supervisor.start_link(children, opts)
    :timer.sleep(:infinity)
  end
end
