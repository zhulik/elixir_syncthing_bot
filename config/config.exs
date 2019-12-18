import Config

config :logger, :console, format: "$time [$level] $metadata $levelpad$message\n"
config :tesla, Tesla.Middleware.Logger, debug: false
config :tesla, adapter: Tesla.Adapter.Httpc

config :ex_gram, json_engine: Poison

if File.exists?("#{Mix.env()}.exs") do
  import_config "#{Mix.env()}.exs"
end
