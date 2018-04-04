defmodule AgentDesktop.PageController do
  use AgentDesktop.Web, :controller
  import ShortMaps

  def real_secret, do: Application.get_env(:agent_desktop, :secret)

  def index(conn, params) do
    IO.inspect(params)
    render(conn, "index.html")
  end

  def show(conn, params = %{"type" => "call", "voter_account" => account_id}) do
    script = AgentDesktop.Scripts.script_for(account_id)
    voter = extract_voter(params)
    render(conn, "call.html", ~m(script voter)a)
  end

  def show(conn, _params = %{"type" => "ready"}) do
    render(conn, "ready.html")
  end

  def show(conn, _params = %{"type" => "notready"}) do
    render(conn, "notready.html")
  end

  def extract_voter(params) do
    Enum.filter(params, fn {k, _v} -> String.starts_with?(k, "voter_") end)
    |> Enum.into(%{})
  end

  def update(conn, ~m(secret)) do
    if secret == real_secret() do
      AgentDesktop.AirtableConfig.update()
      text(conn, "updated")
    else
      text(conn, "wrong secret. contact ben")
    end
  end

  def update(conn, _) do
    text(conn, "missing secret")
  end
end
