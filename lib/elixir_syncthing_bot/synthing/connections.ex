defmodule ElixirSyncthingBot.Syncthing.Api.Connections do
  defstruct [:total, :timestamp]

  @spec rates(__MODULE__, __MODULE__) :: %{in_rate: integer, out_rate: integer}
  def rates(old, new) do
    td = (new.timestamp - old.timestamp) / 1000
    rates(old.total, new.total, td)
  end

  @spec rates(term, term, float) :: %{in_rate: integer, out_rate: integer}
  defp rates(_old_total, _new_total, 0.0) do
    %{in_rate: 0, out_rate: 0}
  end

  defp rates(old_total, new_total, td) do
    in_rate = (new_total.inBytesTotal - old_total.inBytesTotal) / td
    out_rate = (new_total.outBytesTotal - old_total.outBytesTotal) / td
    %{in_rate: round(in_rate), out_rate: round(out_rate)}
  end
end
