defmodule ElixirSyncthingBot.Syncthing.Api do
  use Tesla

  @middleware [
    {Tesla.Middleware.JSON, engine: Poison, engine_opts: [keys: :atoms]},
    Tesla.Middleware.Logger,
    {Tesla.Middleware.Timeout, timeout: 30_000}
  ]

  def client(host: host, token: token) do
    middleware =
      [
        {Tesla.Middleware.BaseUrl, host},
        {Tesla.Middleware.Headers, [{"X-API-Key", token}]}
      ] ++ @middleware

    Tesla.client(middleware)
  end

  def events(client, since \\ nil, limit \\ nil) do
    case Tesla.get(client, "/rest/events", query: [since: since, limit: limit]) do
      {:ok, %{status: 200, body: events}} ->
        {:ok, events}

      {:error, error} ->
        {:error, error}
    end
  end

  def status(client) do
    case Tesla.get(client, "/rest/system/status") do
      {:ok, %{status: 200, body: config}} ->
        {:ok, config}

      {:error, data} ->
        {:error, data}
    end
  end

  def config(client) do
    case Tesla.get(client, "/rest/system/config") do
      {:ok, %{status: 200, body: status}} ->
        {:ok, status}

      {:error, data} ->
        {:error, data}
    end
  end
end
