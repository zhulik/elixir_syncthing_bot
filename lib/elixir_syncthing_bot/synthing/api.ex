defmodule ElixirSyncthingBot.Syncthing.Api do
  defstruct [:client, :host]
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

    %__MODULE__{client: Tesla.client(middleware), host: host}
  end

  def events(api, since \\ nil, limit \\ nil) do
    case Tesla.get(api.client, "/rest/events", query: [since: since, limit: limit]) do
      {:ok, %{status: 200, body: events}} ->
        {:ok, events}

      {:ok, data} ->
        {:error, data}

      {:error, error} ->
        {:error, error}
    end
  end

  def status(api) do
    case Tesla.get(api.client, "/rest/system/status") do
      {:ok, %{status: 200, body: config}} ->
        {:ok, config}

      {:ok, data} ->
        {:error, data}

      {:error, data} ->
        {:error, data}
    end
  end

  def config(api) do
    case Tesla.get(api.client, "/rest/system/config") do
      {:ok, %{status: 200, body: status}} ->
        {:ok, status}

      {:ok, data} ->
        {:error, data}

      {:error, data} ->
        {:error, data}
    end
  end

  def connections(api) do
    case Tesla.get(api.client, "/rest/system/connections") do
      {:ok, %{status: 200, body: connections}} ->
        {:ok, connections}

      {:ok, data} ->
        {:error, data}

      {:error, data} ->
        {:error, data}
    end
  end
end
