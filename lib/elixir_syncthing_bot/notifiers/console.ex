defmodule ElixirSyncthingBot.Notifiers.Console do
  use GenServer

  defmacrop log(msg) do
    quote do
      require Logger

      Logger.info(unquote(msg) <> " #{__MODULE__}")
    end
  end

  def start_link(_) do
    GenServer.start_link(__MODULE__, :ok, name: :notifier)
  end

  def init(:ok) do
    log("Starting...")
    {:ok, []}
  end

  def handle_cast({:process, events}, state) do
    log("Received #{Enum.count(events)}")
    process_events!(events)
    {:noreply, state}
  end

  defp process_events!(events) do
    events
    |> Enum.map(&process_event!/1)
  end

  defp process_event!(%{type: "LoginAttempt"} = event) do
    log("LoginAttempt! username: #{event.data.username} success: #{event.data.success}")
  end

  defp process_event!(%{type: "FolderSummary"} = event) do
    # log("FolderSummary!")
  end

  defp process_event!(_event) do
  end
end
