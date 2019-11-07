defmodule ElixirSyncthingBot.MixProject do
  use Mix.Project

  def project do
    [
      app: :elixir_syncthing_bot,
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      escript: [main_module: ElixirSyncthingBot.Main]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :tesla]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:tesla, "~> 1.3"},
      {:poison, "~> 4.0"},
      {:ex_cli, "~> 0.1.0"}
    ]
  end
end
