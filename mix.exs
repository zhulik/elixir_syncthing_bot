defmodule ElixirSyncthingBot.MixProject do
  use Mix.Project

  def project do
    [
      app: :elixir_syncthing_bot,
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :tesla, :eex],
      mod: {ElixirSyncthingBot, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_gram, "~> 0.8"},
      {:tesla, "~> 1.3"},
      {:poison, "~> 4.0"},
      {:jason, "~> 1.1.2"},
      {:credo, "~> 1.1.5", only: [:dev, :test], runtime: false},
      {:distillery, "~> 2.1", runtime: false},
      {:sentry, "~> 7.0"},
      {:exactor, "~> 2.2.4", warn_missing: false}
    ]
  end

  defp aliases do
    [
      test: "test --no-start"
    ]
  end
end
