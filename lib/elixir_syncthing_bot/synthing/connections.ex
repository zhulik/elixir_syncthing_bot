defmodule ElixirSyncthingBot.Syncthing.Api.Connections do
  defstruct [:total, :timestamp]

  def rates(old, new) do
    td = (new.timestamp - old.timestamp) / 1000
    rates(old.total, new.total, td)
  end

  defp rates(_old_total, _new_total, 0.0) do
    %{in_rate: 0, out_rate: 0}
  end

  defp rates(old_total, new_total, td) do
    in_rate = (new_total.inBytesTotal - old_total.inBytesTotal) / td
    out_rate = (new_total.outBytesTotal - old_total.outBytesTotal) / td
    %{in_rate: round(in_rate), out_rate: round(out_rate)}
  end
end
