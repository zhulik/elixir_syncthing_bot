import Config

config :logger, :console, format: {ElixirSyncthingBot.ColorLogger, :format}
config :tesla, Tesla.Middleware.Logger, debug: false
