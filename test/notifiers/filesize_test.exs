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
      2000 => "1.95 kB",
      3_000_000 => "2.86 MB",
      3_000_000_000 => "2.79 GB",
      3_000_000_000_000 => "2.73 TB",
      3_000_000_000_000_000 => "2.66 PB",
      3_000_000_000_000_000_000 => "2.60 EB"
    }
    |> Enum.map(fn {size, res} ->
      assert(res == Filesize.humanize(size))
    end)
  end
end
