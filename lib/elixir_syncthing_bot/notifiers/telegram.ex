defmodule ElixirSyncthingBot.Notifiers.Telegram do
  use ElixirSyncthingBot.Notifiers.Notifier

  alias ElixirSyncthingBot.Notifiers.FoldersState
  alias ElixirSyncthingBot.Syncthing.Api.Config

  @impl true
  def init(options) do
    log("Starting with options #{inspect(options)}..")

    {:ok,
     %{
       user_id: options["user_id"],
       token: options["token"]
     }}
  end

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

  @dialyzer {:nowarn_function, {:notify_login_attempt, 3}}
  def notify_login_attempt(config, %{data: %{success: true, username: username}}, state) do
    send_message("Successful login attempt at #{Config.my_name(config)} as #{username}!", state)
  end

  def notify_login_attempt(config, %{data: %{success: false, username: username}}, state) do
    send_message("Unsuccessful login attempt at #{Config.my_name(config)} as #{username}!", state)
  end

  defp notify_folders_state(folders_state, _state) when folders_state == %{} do
    IO.puts("Syncrhonization finished!")
  end

  defp notify_folders_state(folders_state, _state) do
    IO.puts(render("folder_summary_notication", state: folders_state))
  end

  defp send_message(text, state) do
    {:ok, message} =
      ExGram.send_message(
        state.user_id,
        text,
        token: state.token
      )

    message
  end
end
