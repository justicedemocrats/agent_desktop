defmodule AgentDesktop do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      supervisor(AgentDesktop.Endpoint, []),
      worker(AgentDesktop.AirtableConfig, []),
      worker(AgentDesktop.Scheduler, []),
      worker(Livevox.Session, []),
      worker(Mongo, [
        [
          name: :mongo,
          database: "agent_desktop",
          username: Application.get_env(:agent_desktop, :mongo_username),
          password: Application.get_env(:agent_desktop, :mongo_password),
          seeds: Application.get_env(:agent_desktop, :mongo_seeds),
          port: Application.get_env(:agent_desktop, :mongo_port)
        ]
      ])
    ]

    opts = [strategy: :one_for_one, name: AgentDesktop.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    AgentDesktop.Endpoint.config_change(changed, removed)
    :ok
  end
end
