import Config

config :logger, :console, format: "$time [$level] $metadata $levelpad$message\n"
config :tesla, Tesla.Middleware.Logger, debug: false

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
