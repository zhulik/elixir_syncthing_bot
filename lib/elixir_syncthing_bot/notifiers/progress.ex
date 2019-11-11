defmodule ElixirSyncthingBot.Notifiers.Progress do
  @full "█"
  @empty "░"

  def render(current, total, length) do
    percent = progress(current, total)

    percent
    |> normalize_percent
    |> render_percent(length)
  end

  defp progress(_, 0) do
    100
  end

  defp progress(current, total) do
    100 * current / total
  end

  defp render_percent(percent, length) do
    full_count =
      (percent / 100 * 20)
      |> Float.ceil()
      |> trunc

    "#{String.duplicate(@full, full_count)}#{String.duplicate(@empty, length - full_count)}"
  end

  defp normalize_percent(percent) when percent >= 100 do
    100
  end

  defp normalize_percent(percent) when percent <= 0 do
    0
  end

  defp normalize_percent(percent) do
    percent
  end
end
