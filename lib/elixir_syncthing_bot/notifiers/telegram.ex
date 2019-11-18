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
       token: options["token"],
       last_state_message_text: nil,
       last_state_message_id: nil
     }}
  end

  @impl true
  def process_event([config: config, event: %{type: "LoginAttempt"} = event], state) do
    log("LoginAttempt! username: #{event.data.username} success: #{event.data.success}")
    notify_login_attempt(config, event, state)
    state
  end

  @impl true
  def process_event([config: config, event: %{type: "FolderSummary"} = event], state) do
    log("FolderSummary!")

    case FoldersState.add_event(config, event) do
      {true, folders_state} ->
        notify_folders_state(folders_state, state)

      _ ->
        state
    end
  end

  @impl true
  def process_event(_event, state) do
    state
  end

  @dialyzer {:nowarn_function, {:notify_login_attempt, 3}}
  def notify_login_attempt(config, %{data: %{success: true, username: username}}, state) do
    send_message("Successful login attempt at #{Config.my_name(config)} as #{username}!", state)
  end

  def notify_login_attempt(config, %{data: %{success: false, username: username}}, state) do
    send_message("Unsuccessful login attempt at #{Config.my_name(config)} as #{username}!", state)
  end

  defp notify_folders_state(folders_state, %{last_state_message_id: message_id} = state)
       when folders_state == %{} do
    update_message(message_id, "Syncrhonization finished!", state)
    %{state | last_state_message_id: nil, last_state_message_text: nil}
  end

  defp notify_folders_state(folders_state, %{last_state_message_id: nil} = state) do
    text = render("folder_summary_notication", state: folders_state)

    %{message_id: message_id} = send_message(text, state)
    %{state | last_state_message_id: message_id, last_state_message_text: text}
  end

  defp notify_folders_state(
         folders_state,
         %{last_state_message_id: message_id, last_state_message_text: last_state_message_text} =
           state
       ) do
    text = render("folder_summary_notication", state: folders_state)

    if text != last_state_message_text do
      update_message(message_id, text, state)
      %{state | last_state_message_text: text}
    else
      state
    end
  end

  @dialyzer {:nowarn_function, {:send_message, 2}}
  defp send_message(text, state) do
    {:ok, message} =
      ExGram.send_message(
        state.user_id,
        text,
        token: state.token,
        parse_mode: :markdown
      )

    message
  end

  @dialyzer {:nowarn_function, {:update_message, 3}}
  defp update_message(message_id, text, state) do
    {:ok, message} =
      ExGram.edit_message_text(
        text,
        chat_id: state.user_id,
        message_id: message_id,
        token: state.token,
        parse_mode: :markdown
      )

    message
  end
end
