use Mix.Config

config :agent_desktop, AgentDesktop.Endpoint,
  http: [:inet6, port: {:system, "PORT"}],
  url: [host: "example.com", port: 80],
  cache_static_manifest: "priv/static/cache_manifest.json",
  server: true

config :agent_desktop,
  airtable_key: "${AIRTABLE_KEY}",
  airtable_base: "${AIRTABLE_BASE}",
  airtable_table_name: "${AIRTABLE_TABLE_NAME}"

config :agent_desktop, secret: "${SECRET}"
