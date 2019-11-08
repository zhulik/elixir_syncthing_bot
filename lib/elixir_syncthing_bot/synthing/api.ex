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

  def events(client, since \\ nil) do
    Tesla.get(client, "/rest/events", query: [since: since])
  end
end
