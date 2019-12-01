config :sentry,
  dsn: "https://141d9b8aed2749e4b140616c140ca240@sentry.io/1840055",
  environment_name: :prod,
  enable_source_code_context: true,
  root_source_code_path: File.cwd!(),
  tags: %{
    env: "production"
  },
  included_environments: [:prod]
