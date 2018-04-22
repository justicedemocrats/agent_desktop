defmodule AgentDesktop.SecretPlug do
  import Plug.Conn

  def secret, do: Application.get_env(:agent_desktop, :secret)

  def init(o), do: o

  def call(conn = %Plug.Conn{params: %{"secret" => input_secret}}, _) do
    if input_secret == secret() do
      conn
    else
      send_resp(conn, 200, "wrong secret. contact ben")
    end
  end

  def call(conn, _) do
    send_resp(conn, 200, "missing secret")
  end
end
