defmodule ElixirSyncthingBot.Notifiers.Console do
  use GenServer

  alias ElixirSyncthingBot.Notifiers.FoldersState
  alias ElixirSyncthingBot.Syncthing.Api.Config

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

  defp process_event!(config: config, event: %{type: "LoginAttempt"} = event) do
    log("LoginAttempt! username: #{event.data.username} success: #{event.data.success}")
    notify_login_attempt(config, event)
  end

  defp process_event!(config: config, event: %{type: "FolderSummary"} = event) do
    log("FolderSummary!")
    notify_folders_state(FoldersState.add_event(config, event))
  end

  defp process_event!(_event) do
  end

  def notify_login_attempt(config, %{data: %{success: true, username: username}}) do
    IO.puts("Successful login attempt at #{Config.my_name(config)} as #{username}!")
  end

  def notify_login_attempt(config, %{data: %{success: false, username: username}}) do
    IO.puts("Unsuccessful login attempt at #{Config.my_name(config)} as #{username}!")
  end

  defp notify_folders_state(state) do
  end
end
