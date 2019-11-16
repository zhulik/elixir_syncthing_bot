defmodule ElixirSyncthingBot.Notifiers.Notifier do
  defmacro __using__(_) do
    quote do
      use GenServer
      @behaviour ElixirSyncthingBot.Notifiers.Notifier

      alias ElixirSyncthingBot.Notifiers.FoldersState
      alias ElixirSyncthingBot.Syncthing.Api.Config

      defmacrop log(msg) do
        quote do
          require Logger

          Logger.info(unquote(msg) <> " #{__MODULE__}")
        end
      end

      def start_link(options) do
        GenServer.start_link(__MODULE__, options,
          name: {:via, Registry, {Registry.ElixirSyncthingBot, :notifier}}
        )
      end

      def init(options) do
        log("Starting with options #{options}..")
        {:ok, []}
      end

      def handle_cast({:process, events}, state) do
        log("Received #{Enum.count(events)}")
        process_events(events)
        {:noreply, state}
      end

      defp process_events(events) do
        Enum.map(events, &process_event/1)
      end

      defp view_path(name) do
        "#{Application.app_dir(:elixir_syncthing_bot)}/priv/views/#{notifier_name()}/#{name}.eex"
      end

      defp notifier_name do
        __MODULE__ |> to_string() |> String.split(".") |> List.last() |> Macro.underscore()
      end

      defp render(name, args) do
        EEx.eval_file(
          view_path(name),
          args
        )
      end
    end
  end

  @callback process_event(term) :: term
end
