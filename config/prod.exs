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

config :actionkit,
  base: "${AK_BASE}",
  username: "${AK_USERNAME}",
  password: "${AK_PASSWORD}"

config :agent_desktop,
  mongo_username: "${MONGO_USERNAME}",
  mongo_password: "${MONGO_PASSWORD}",
  mongo_seeds: [
    "${MONGO_SEED_1}",
    "${MONGO_SEED_2}"
  ],
  mongo_port: "${MONGO_PORT}"

config :agent_desktop,
  lv_access_token: "${LIVEVOX_ACCESS_TOKEN}",
  lv_clientname: "${LIVEVOX_CLIENT_NAME}",
  lv_username: "${LIVEVOX_USERNAME}",
  lv_password: "${LIVEVOX_PASSWORD}"

config :agent_desktop, secret: "${SECRET}"
