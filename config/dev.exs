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
  email_webhook: System.get_env("EMAIL_WEBHOOK")

config :agent_desktop, secret: "secret"
