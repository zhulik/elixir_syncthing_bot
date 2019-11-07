defmodule ElixirSyncthingBotTest do
  use ExUnit.Case
  doctest ElixirSyncthingBot

  test "greets the world" do
    assert ElixirSyncthingBot.hello() == :world
  end
end
