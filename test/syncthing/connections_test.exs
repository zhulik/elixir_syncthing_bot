defmodule ElixirSyncthingBot.Syncthing.Api.ConnectionsTest do
  use ExUnit.Case

  alias ElixirSyncthingBot.Syncthing.Api.Connections

  defp connections(inBytes, outBytes, timestamp) do
    %Connections{total: %{inBytesTotal: inBytes, outBytesTotal: outBytes}, timestamp: timestamp}
  end

  test "rates" do
    %{
      [connections(0, 0, 0), connections(0, 0, 0)] => %{in_rate: 0, out_rate: 0},
      [connections(0, 0, 0), connections(1000, 1000, 1000)] => %{in_rate: 1000, out_rate: 1000},
      [connections(0, 0, 0), connections(4000, 2000, 2000)] => %{in_rate: 2000, out_rate: 1000},
      [connections(1000, 2000, 3000), connections(4000, 4000, 13_000)] => %{
        in_rate: 300,
        out_rate: 200
      }
    }
    |> Enum.map(fn {[old, new], res} ->
      assert(res == Connections.rates(old, new))
    end)
  end
end
