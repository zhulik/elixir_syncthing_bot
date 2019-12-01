import Config

config :logger, :console, format: "$time [$level] $metadata $levelpad$message\n"
config :tesla, Tesla.Middleware.Logger, debug: false
config :tesla, adapter: Tesla.Adapter.Httpc

config :ex_gram, json_engine: Poison

config :sentry,
  dsn: "${SENTRY_DSN}",
  environment_name: Mix.env(),
  enable_source_code_context: true,
  root_source_code_path: File.cwd!(),
  tags: %{
    env: Mix.env()
  },
  included_environments: [Mix.env()]

if File.exists?("#{Mix.env()}.exs") do
  import_config "#{Mix.env()}.exs"
end
