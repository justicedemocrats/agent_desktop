defmodule AgentDesktop.PageController do
  use AgentDesktop.Web, :controller
  import ShortMaps

  @cookie_minutes 10

  def real_secret, do: Application.get_env(:agent_desktop, :secret)

  def index(conn, params) do
    render(conn, "index.html")
  end

  def show(
        conn,
        params = %{"type" => "call", "voter_account" => account_id, "service_id" => service_id}
      ) do
    script = AgentDesktop.Scripts.script_for(~m(account_id service_id))
    voter = extract_voter(params)
    caller = params["caller"]

    conn
    |> put_resp_cookie("last_voter_account", account_id, max_age: @cookie_minutes * 60)
    |> put_resp_cookie("last_service_id", service_id, max_age: @cookie_minutes * 60)
    |> render("call.html", ~m(script voter caller)a)
  end

  def show(
        conn,
        params = %{"type" => "call", "voter_account" => account_id, "caller" => caller}
      ) do
    script = AgentDesktop.Scripts.script_for(account_id)
    voter = extract_voter(params)

    conn
    |> put_resp_cookie("last_voter_account", account_id, max_age: @cookie_minutes * 60)
    |> render("call.html", ~m(script voter caller)a)
  end

  def show(conn, _params = %{"type" => "ready"}) do
    ~m(ready_html service_name script_include) = get_stage_htmls(conn)
    data = get_live_calling_data(service_name)
    render(conn, "ready.html", ~m(ready_html data script_include)a)
  end

  def show(conn, _params = %{"type" => "notready"}) do
    ~m(not_ready_html service_name script_include) = get_stage_htmls(conn)
    data = get_live_calling_data(service_name)
    render(conn, "notready.html", ~m(not_ready_html data script_include)a)
  end

  def show(conn, _params = ~m(candidate)) do
    case AgentDesktop.Scripts.script_for_candidate(candidate) do
      nil ->
        conn
        |> put_status(404)
        |> text("Not found")

      script ->
        voter = %{}
        caller = "CALLER"
        render(conn, "call.html", ~m(script voter caller)a)
    end
  end

  def get_stage_htmls(conn) do
    if Map.has_key?(conn.cookies, "last_voter_account") do
      AgentDesktop.Scripts.script_for(%{
        "account_id" => conn.cookies["last_voter_account"],
        "service_id" => conn.cookies["last_service_id"]
      }).listing
    else
      AgentDesktop.Scripts.script_for("FALLBACK").listing
    end
  end

  def get_live_calling_data(nil) do
    %{}
  end

  def get_live_calling_data(service_name) do
    try do
      %{body: body} =
        HTTPotion.get!(
          Application.get_env(:agent_desktop, :live_info_url),
          query: ~m(service_name)
        )

      ~m(caller_count wait_time) = Poison.decode!(body)

      selected =
        cond do
          caller_count <= 3 -> "low_callers"
          caller_count <= 7 -> "mid_callers"
          caller_count <= 12 -> "high_callers"
          caller_count <= 20 -> "super_callers"
          true -> "mega_callers"
        end

      %{}
      |> Map.put(selected, 1)
      |> Map.merge(~m(caller_count wait_time))
    rescue
      _ -> %{}
    end
  end

  def extract_voter(params) do
    params
    |> Enum.filter(fn {k, _v} -> String.starts_with?(k, "voter_") end)
    |> Enum.map(fn {k, v} -> {String.replace(k, "voter_", ""), v} end)
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
