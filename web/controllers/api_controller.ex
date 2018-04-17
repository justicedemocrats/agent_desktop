defmodule AgentDesktop.ApiController do
  use AgentDesktop.Web, :controller
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
      if email_or_text == "text" do
        body =
          params
          |> Map.drop(~w(widget_id email_or_text number))
          |> Map.put("to", params["number"])
          |> Map.put("message", AgentDesktop.AirtableConfig.get_all().contact_widgets[widget_id])

        HTTPotion.post(
          Application.get_env(:agent_desktop, :text_webhook),
          body: Poison.encode!(body) |> IO.inspect()
        )
      else
        body =
          params
          |> Map.drop(~w(widget_id email_or_text number original_number email))
          |> Map.put("to", params["email"])
          |> Map.put("message", AgentDesktop.AirtableConfig.get_all().contact_widgets[widget_id])

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
end
