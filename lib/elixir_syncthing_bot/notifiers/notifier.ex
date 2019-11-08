defmodule ElixirSyncthingBot.Notifiers.Notifier do
  def notifier(:console) do
    ElixirSyncthingBot.Notifiers.Console
  end

  def process!(events) do
    GenServer.cast(:notifier, {:process, events})
  end
end
