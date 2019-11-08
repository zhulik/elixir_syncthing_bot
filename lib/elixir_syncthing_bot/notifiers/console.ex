defmodule ElixirSyncthingBot.Notifiers.Console do
  @important_events ["FolderSummary", "LoginAttempt"]

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

  def process!(events) do
    GenServer.cast(:notifier, {:process, events})
  end

  def handle_cast({:process, events}, state) do
    log("Received #{Enum.count(events)}")
    process_events!(events)
    {:noreply, state}
  end

  defp process_events!(events) do
    important_events =
      events
      |> Enum.filter(fn event -> Enum.member?(@important_events, event.type) end)
      |> Enum.map(&process_event!/1)
  end

  defp process_event!(%{type: "LoginAttempt"} = event) do
    log("LoginAttempt!")
  end

  defp process_event!(%{type: "FolderSummary"} = event) do
    log("FolderSummary!")
  end

  # defp process_event!(event) do
  # end
end
