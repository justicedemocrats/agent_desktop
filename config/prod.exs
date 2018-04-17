use Mix.Config

config :agent_desktop, AgentDesktop.Endpoint,
  http: [:inet6, port: {:system, "PORT"}],
  url: [host: "example.com", port: 80],
  server: true

config :agent_desktop,
  airtable_key: "${AIRTABLE_KEY}",
  airtable_base: "${AIRTABLE_BASE}",
  airtable_table_name: "${AIRTABLE_TABLE_NAME}"

config :agent_desktop,
  sorting_hat_url: "${SORTING_HAT_URL}",
  sorting_hat_secret: "${SORTING_HAT_SECRET}"

config :agent_desktop,
  text_webhook: "${TEXT_WEBHOOK}",
  email_webhook: "${EMAIL_WEBHOOK}",
  live_info_url: "${LIVE_INFO_URL}"

config :agent_desktop, secret: "${SECRET}"
