defmodule AgentDesktop.PageController do
  use AgentDesktop.Web, :controller
  import ShortMaps

  def index(conn, params) do
    IO.inspect(params)
    render(conn, "index.html")
  end

  def show(conn, params = %{"type" => "call", "voter_account" => account_id}) do
    script = AgentDesktop.Scripts.script_for(account_id)
    voter = extract_voter(params)
    render(conn, "call.html", ~m(script voter)a)
  end

  def show(conn, params = %{"type" => "ready"}) do
    render(conn, "ready.html")
  end

  def show(conn, params = %{"type" => "notready"}) do
    render(conn, "notready.html")
  end

  def extract_voter(params) do
    Enum.filter(params, fn {k, _v} -> String.starts_with?(k, "voter_") end)
    |> Enum.into(%{})
  end
end
