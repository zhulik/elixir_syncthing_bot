defmodule ElixirSyncthingBot.Notifiers.Filesize do
  @units {"B", "kB", "MB", "GB", "TB", "PB", "EB"}

  def humanize(0) do
    "0.00 B"
  end

  def humanize(size) when size < 0 do
    "0.00 B"
  end

  @spec humanize(integer) :: String.t()
  def humanize(size) do
    exp = (:math.log(size) / :math.log(1024)) |> trunc

    exp =
      if exp > 6 do
        6
      else
        exp
      end

    "#{:io_lib.format("~.2f", [size / :math.pow(1024, exp)])} #{@units |> elem(exp)}"
  end
end
