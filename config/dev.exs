use Mix.Config

config :agent_desktop, AgentDesktop.Endpoint,
  http: [port: 4000],
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  watchers: [
    node: [
      "node_modules/parcel-bundler/bin/cli.js",
      "watch",
      "web/static/js/app.js",
      "--out-dir",
      "priv/static/js"
    ]
  ]

# Watch static and templates for browser reloading.
config :agent_desktop, AgentDesktop.Endpoint,
  live_reload: [
    patterns: [
      ~r{priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$},
      ~r{priv/gettext/.*(po)$},
      ~r{web/views/.*(ex)$},
      ~r{web/templates/.*(eex)$}
    ]
  ]

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20

config :agent_desktop,
  airtable_key: System.get_env("AIRTABLE_KEY"),
  airtable_base: System.get_env("AIRTABLE_BASE"),
  airtable_table_name: System.get_env("AIRTABLE_TABLE_NAME")

config :agent_desktop,
  sorting_hat_url: System.get_env("SORTING_HAT_URL"),
  sorting_hat_secret: System.get_env("SORTING_HAT_SECRET")

config :agent_desktop,
  text_webhook: System.get_env("TEXT_WEBHOOK"),
  email_webhook: System.get_env("EMAIL_WEBHOOK"),
  live_info_url: System.get_env("LIVE_INFO_URL")

config :actionkit,
  base: System.get_env("AK_BASE"),
  username: System.get_env("AK_USERNAME"),
  password: System.get_env("AK_PASSWORD")

config :agent_desktop,
  mongo_username: System.get_env("MONGO_USERNAME"),
  mongo_password: System.get_env("MONGO_PASSWORD"),
  mongo_seeds: [
    System.get_env("MONGO_SEED_1"),
    System.get_env("MONGO_SEED_2")
  ],
  mongo_port: System.get_env("MONGO_PORT")

config :agent_desktop,
  lv_access_token: System.get_env("LIVEVOX_ACCESS_TOKEN"),
  lv_clientname: System.get_env("LIVEVOX_CLIENT_NAME"),
  lv_username: System.get_env("LIVEVOX_USERNAME"),
  lv_password: System.get_env("LIVEVOX_PASSWORD")

config :agent_desktop, secret: "secret"
