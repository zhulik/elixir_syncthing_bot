import Config

config :sentry,
  dsn: System.fetch_env!("SENTRY_DSN"),
  environment_name: :prod,
  enable_source_code_context: true,
  root_source_code_path: File.cwd!(),
  tags: %{
    env: :prod
  },
  included_environments: [:prod]
