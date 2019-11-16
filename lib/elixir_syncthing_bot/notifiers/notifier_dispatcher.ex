defmodule ElixirSyncthingBot.Notifiers.NotifierDispatcher do
  def notifier("console", options) do
    {ElixirSyncthingBot.Notifiers.Console, options}
  end

  def process!(events) do
    GenServer.cast({:via, Registry, {Registry.ElixirSyncthingBot, :notifier}}, {:process, events})
  end
end
