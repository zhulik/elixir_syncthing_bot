defmodule ElixirSyncthingBot.Notifiers.Console do
  use GenServer

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
    process_events!(events)
    {:noreply, state}
  end

  defp process_events!(events) do
    Enum.map(events, &process_event!/1)
  end

  defp process_event!(config: config, event: %{type: "LoginAttempt"} = event) do
    log("LoginAttempt! username: #{event.data.username} success: #{event.data.success}")
    notify_login_attempt(config, event)
  end

  defp process_event!(config: config, event: %{type: "FolderSummary"} = event) do
    log("FolderSummary!")
    folders_state = FoldersState.add_event(config, event)
    notify_folders_state(folders_state)
  end

  defp process_event!(_event) do
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
