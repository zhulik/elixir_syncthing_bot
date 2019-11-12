import Config

config :logger, :console, format: "$time [$level] $metadata $levelpad$message\n"
config :tesla, Tesla.Middleware.Logger, debug: false
