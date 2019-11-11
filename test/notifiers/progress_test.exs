defmodule ElixirSyncthingBot.Notifiers.ProgressTest do
  use ExUnit.Case

  alias ElixirSyncthingBot.Notifiers.Progress

  test "render" do
    %{
      [-100, 100] => "░░░░░░░░░░░░░░░░░░░░",
      [0, 100] => "░░░░░░░░░░░░░░░░░░░░",
      [10, 100] => "██░░░░░░░░░░░░░░░░░░",
      [50, 100] => "██████████░░░░░░░░░░",
      [90, 100] => "██████████████████░░",
      [100, 100] => "████████████████████",
      [1000, 100] => "████████████████████"
    }
    |> Enum.map(fn {[c, t], res} ->
      assert(res == Progress.render(c, t, 20))
    end)
  end
end
