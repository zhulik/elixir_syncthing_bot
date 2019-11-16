defmodule ElixirSyncthingBot.Notifiers.Console do
  use ElixirSyncthingBot.Notifiers.Notifier

  alias ElixirSyncthingBot.Notifiers.FoldersState
  alias ElixirSyncthingBot.Syncthing.Api.Config

  @summary_message """
  <%= for {server, folders} <- state do %>
  <%= server.name %>
  <%= for {folder, progress} <- folders do %>
    <%= folder.name %> <%= ElixirSyncthingBot.Notifiers.Progress.render(progress.current, progress.total, 20)%> <%= ElixirSyncthingBot.Notifiers.Filesize.humanize(progress.current) %> / <%= ElixirSyncthingBot.Notifiers.Filesize.humanize(progress.total) %>
  <% end %>
  <% end %>
  """

  @impl true
  def process_event(config: config, event: %{type: "LoginAttempt"} = event) do
    log("LoginAttempt! username: #{event.data.username} success: #{event.data.success}")
    notify_login_attempt(config, event)
  end

  @impl true
  def process_event(config: config, event: %{type: "FolderSummary"} = event) do
    log("FolderSummary!")

    case FoldersState.add_event(config, event) do
      {true, folders_state} ->
        notify_folders_state(folders_state)

      _ ->
        nil
    end
  end

  @impl true
  def process_event(_event) do
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
    IO.puts(EEx.eval_string(@summary_message, state: state))
  end
end
