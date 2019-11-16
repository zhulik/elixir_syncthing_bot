defmodule ElixirSyncthingBot.Notifiers.NotifierDispatcher do
  def notifier("console", _options) do
    ElixirSyncthingBot.Notifiers.Console
  end

  def process!(events) do
    GenServer.cast({:via, Registry, {Registry.ElixirSyncthingBot, :notifier}}, {:process, events})
  end
end
