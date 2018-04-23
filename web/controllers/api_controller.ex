defmodule AgentDesktop.ApiController do
  use AgentDesktop.Web, :controller
  alias NimbleCSV.RFC4180, as: CSV
  import ShortMaps

  def lookup(conn, ~m(number)) do
    ~m(body)a =
      HTTPotion.post(
        Application.get_env(:agent_desktop, :sorting_hat_url),
        query: %{
          "phone" => number,
          "secret" => Application.get_env(:agent_desktop, :sorting_hat_secret)
        }
      )

    is_mobile =
      case Poison.decode(body) do
        {:ok, %{"result" => "mobile"}} -> true
        _ -> false
      end

    json(conn, ~m(is_mobile))
  end

  def create(conn, params = ~m(widget_id email_or_text)) do
    spawn(fn ->
      ~m(content image) = AgentDesktop.AirtableConfig.get_all().contact_widgets[widget_id]

      body =
        params
        |> Map.drop(~w(widget_id email_or_text number original_number email))
        |> Map.put("message", content)

      body = if image != nil, do: Map.put(body, "image", image), else: body

      if email_or_text == "text" do
        body =
          body
          |> Map.put("to", params["number"])

        HTTPotion.post(
          Application.get_env(:agent_desktop, :text_webhook),
          body: Poison.encode!(body)
        )
      else
        body =
          body
          |> Map.put("to", params["email"])

        HTTPotion.post(
          Application.get_env(:agent_desktop, :email_webhook),
          body: Poison.encode!(body)
        )
      end
    end)

    text(conn, "OK")
  end

  def get_events(conn, _params = ~m(candidate)) do
    %{body: body} =
      HTTPotion.get("https://map.justicedemocrats.com/api/events", query: ~m(candidate))

    all_events = Poison.decode!(body)

    schema =
      AgentDesktop.AirtableConfig.get_all().listings
      |> Enum.map(fn {_, m} -> m end)
      |> Enum.filter(&(&1["event_slug"] == candidate))
      |> List.first()
      |> Map.get("events_filter", nil)

    filter_fn =
      case schema do
        nil ->
          fn _ -> true end

        encoded ->
          json_schema = encoded |> Poison.decode!()

          fn ev ->
            case ExJsonSchema.Validator.validate(json_schema, ev) do
              :ok -> true
              _ -> false
            end
          end
      end

    events = Enum.filter(all_events, &filter_fn.(&1))
    json(conn, ~m(events))
  end

  def rsvp(conn, _params = ~m(event_id first last phone email)) do
    Ak.Api.post(
      "action",
      body: %{
        "page" => "signup",
        "event_id" => event_id,
        "email" => email,
        "first_name" => first,
        "last_name" => last,
        "number" => phone,
        "event_signup_ground_rules" => 1
      }
    )

    text(conn, "OK")
  end

  def form_submit(conn, params) do
    timestamp = DateTime.utc_now()
    data = Map.merge(params, ~m(timestamp))
    {:ok, _} = Mongo.insert_one(:mongo, "submissions", data)
    text(conn, "OK")
  end

  def get_submissions(conn, params = ~m(candidate form)) do
    time_query = extract_time_query(params)
    candidate_query = %{"candidate" => String.downcase(candidate)}

    form_query =
      case form |> String.downcase() |> String.split(",") do
        [single] -> %{"form" => single}
        forms when is_list(forms) -> %{"form" => %{"$in" => forms}}
      end

    query =
      candidate_query
      |> Map.merge(time_query)
      |> Map.merge(form_query)

    ~m(from to) =
      case time_query do
        %{"timestamp" => %{"$gt" => from, "$lt" => to}} -> ~m(from to)
        _ -> %{"from" => "start", "to" => "end"}
      end

    data =
      Mongo.find(:mongo, "submissions", query)
      |> Enum.map(&Map.drop(&1, ~w(_id)))

    if params["type"] == "csv" do
      contents = convert_to_csv(data)

      conn
      |> put_resp_content_type("text/csv")
      |> put_resp_header(
        "content-disposition",
        "attachment; filename=\"#{candidate}|#{form}|#{fnify_date(from)}-#{fnify_date(to)}.csv\""
      )
      |> send_resp(200, contents)
    else
      json(conn, data)
    end
  end

  def get_submissions(conn, params) do
    body =
      cond do
        not Map.has_key?(params, "candidate") ->
          %{"error" => "Missing required parameter: [candidate]"}

        not Map.has_key?(params, "form") ->
          %{"error" => "Missing required parameter: [form]"}

        true ->
          %{"error" => "Unknown: contact Ben."}
      end

    conn
    |> put_status(400)
    |> json(body)
  end

  def extract_time_query(~m(start_day count)) do
    now = Timex.now("America/New_York")
    start_datetime = Timex.parse!(start_day, "{M}-{D}")
    {count, _} = Integer.parse(count)

    start_datetime_est =
      Timex.set(
        now,
        year: now.year,
        day: start_datetime.day,
        month: start_datetime.month,
        hour: 0,
        minute: 0,
        second: 0
      )

    end_datetime_est = Timex.shift(start_datetime_est, days: count)
    %{"timestamp" => %{"$gt" => start_datetime_est, "$lt" => end_datetime_est}}
  end

  def extract_time_query(_) do
    %{}
  end

  def fnify_date(dt = %DateTime{}), do: DateTime.to_iso8601(dt)
  def fnify_date(dt), do: dt

  def convert_to_csv(contents) do
    normalized =
      Enum.map(contents, fn ~m(timestamp data) ->
        Enum.map(data, fn
          {k, v} when is_list(v) -> {k, Enum.join(v, ",")}
          {k, v} -> {k, v}
        end)
        |> Enum.into(%{})
        |> Map.merge(~m(timestamp))
      end)

    ordered = ~w(voter_id timestamp first_name last_name)

    custom_columns =
      Enum.flat_map(normalized, &Map.keys/1)
      |> MapSet.new()
      |> MapSet.difference(MapSet.new(ordered))
      |> MapSet.to_list()

    columns = Enum.concat(ordered, custom_columns)

    Enum.concat(
      [columns],
      Enum.map(normalized, fn row ->
        Enum.map(columns, fn
          "voter_id" -> Map.get(row, "voter_id") |> String.split("-") |> List.last()
          col -> Map.get(row, col)
        end)
      end)
    )
    |> CSV.dump_to_iodata()
    |> IO.iodata_to_binary()
  end
end
