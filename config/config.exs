import Config

config :logger, :console, format: "$time $metadata[$level] $levelpad$message\n"
config :tesla, Tesla.Middleware.Logger, debug: false
