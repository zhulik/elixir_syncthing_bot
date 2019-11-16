defmodule ElixirSyncthingBot.Notifiers.Telegram do
  use ElixirSyncthingBot.Notifiers.Notifier

  alias ElixirSyncthingBot.Notifiers.FoldersState
  alias ElixirSyncthingBot.Syncthing.Api.Config

  @impl true
  def process_event([config: config, event: %{type: "LoginAttempt"} = event], state) do
    log("LoginAttempt! username: #{event.data.username} success: #{event.data.success}")
    notify_login_attempt(config, event, state)
  end

  @impl true
  def process_event([config: config, event: %{type: "FolderSummary"} = event], state) do
    log("FolderSummary!")

    case FoldersState.add_event(config, event) do
      {true, folders_state} ->
        notify_folders_state(folders_state, state)

      _ ->
        nil
    end
  end

  @impl true
  def process_event(_event, _state) do
  end

  def notify_login_attempt(config, %{data: %{success: true, username: username}}, state) do
    {:ok, _} =
      ExGram.send_message(
        state.options["user_id"],
        "Successful login attempt at #{Config.my_name(config)} as #{username}!",
        token: state.options["token"]
      )
  end

  def notify_login_attempt(config, %{data: %{success: false, username: username}}, state) do
    {:ok, _} =
      ExGram.send_message(
        state.options["user_id"],
        "Unsuccessful login attempt at #{Config.my_name(config)} as #{username}!",
        token: state.options["token"]
      )
  end

  defp notify_folders_state(folders_state, _state) when folders_state == %{} do
    IO.puts("Syncrhonization finished!")
  end

  defp notify_folders_state(folders_state, _state) do
    IO.puts(render("folder_summary_notication", state: folders_state))
  end
end
