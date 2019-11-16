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

      def start_link(_) do
        GenServer.start_link(__MODULE__, :ok,
          name: {:via, Registry, {Registry.ElixirSyncthingBot, :notifier}}
        )
      end

      def init(:ok) do
        log("Starting...")
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
    end
  end

  @callback process_event(term) :: term
end
