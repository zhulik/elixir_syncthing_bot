defmodule ElixirSyncthingBot.Notifiers.NotifierDispatcher do
  def notifier("console", options) do
    {ElixirSyncthingBot.Notifiers.Console, options}
  end

  def notifier("telegram", options) do
    options =
      options
      |> String.split(", ")
      |> Enum.map(fn option -> String.split(option, "=") end)
      |> Enum.reduce(%{}, fn option, acc ->
        [k, v] = option
        Map.merge(acc, %{k => v})
      end)

    {ElixirSyncthingBot.Notifiers.Telegram, options}
  end

  def process!(events) do
    GenServer.cast({:via, Registry, {Registry.ElixirSyncthingBot, :notifier}}, {:process, events})
  end
end
