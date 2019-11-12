defmodule ElixirSyncthingBot.Notifiers.FilesizeTest do
  use ExUnit.Case

  alias ElixirSyncthingBot.Notifiers.Filesize

  test "humanize" do
    %{
      0 => "0.00 B",
      10 => "10.00 B",
      100 => "100.00 B",
      300 => "300.00 B",
      600 => "600.00 B",
      2000 => "1.95 KiB",
      3_000_000 => "2.86 MiB",
      3_000_000_000 => "2.79 GiB",
      3_000_000_000_000 => "2.73 TiB",
      3_000_000_000_000_000 => "2.66 PiB",
      3_000_000_000_000_000_000 => "2.60 EiB"
    }
    |> Enum.map(fn {size, res} ->
      assert(res == Filesize.humanize(size))
    end)
  end
end
