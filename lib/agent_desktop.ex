defmodule AgentDesktop do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      supervisor(AgentDesktop.Endpoint, []),
      worker(AgentDesktop.AirtableConfig, [])
    ]

    opts = [strategy: :one_for_one, name: AgentDesktop.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    AgentDesktop.Endpoint.config_change(changed, removed)
    :ok
  end
end
