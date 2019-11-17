defmodule ElixirSyncthingBot.Notifiers.Console do
  use ElixirSyncthingBot.Notifiers.Notifier

  alias ElixirSyncthingBot.Notifiers.FoldersState
  alias ElixirSyncthingBot.Syncthing.Api.Config

  @impl true
  def init(options) do
    log("Starting with options #{inspect(options)}..")
    {:ok, %{}}
  end

  @impl true
  def process_event([config: config, event: %{type: "LoginAttempt"} = event], state) do
    log("LoginAttempt! username: #{event.data.username} success: #{event.data.success}")
    notify_login_attempt(config, event)
    state
  end

  @impl true
  def process_event([config: config, event: %{type: "FolderSummary"} = event], state) do
    log("FolderSummary!")

    case FoldersState.add_event(config, event) do
      {true, folders_state} ->
        notify_folders_state(folders_state)
        state

      _ ->
        state
    end
  end

  @impl true
  def process_event(_event, state) do
    state
  end

  def notify_login_attempt(config, %{data: %{success: true, username: username}}) do
    IO.puts("Successful login attempt at #{Config.my_name(config)} as #{username}!")
  end

  def notify_login_attempt(config, %{data: %{success: false, username: username}}) do
    IO.puts("Unsuccessful login attempt at #{Config.my_name(config)} as #{username}!")
  end

  defp notify_folders_state(state) when state == %{} do
    IO.puts("Syncrhonization finished!")
  end

  defp notify_folders_state(state) do
    IO.puts(render("folder_summary_notication", state: state))
  end
end
