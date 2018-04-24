defmodule AgentDesktop.AirtableConfig do
  use Agent
  require Logger
  import ShortMaps

  def key, do: Application.get_env(:agent_desktop, :airtable_key)
  def base, do: Application.get_env(:agent_desktop, :airtable_base)
  def root_table, do: Application.get_env(:agent_desktop, :airtable_table_name)

  def start_link do
    Agent.start_link(
      fn ->
        update_all()
      end,
      name: __MODULE__
    )
  end

  def update() do
    Agent.update(
      __MODULE__,
      fn _current ->
        update_all()
      end,
      20_000
    )

    Logger.info("[calling scripts]: updated at #{inspect(DateTime.utc_now())}")
  end

  def get_all do
    Agent.get(__MODULE__, & &1)
  end

  def update_all do
    listings = root_table() |> fetch_all() |> process_listings()

    scripts =
      Enum.map(listings, fn {slug, ~m(reference_name)} ->
        config = reference_name |> fetch_all() |> process_script()
        {slug, config}
      end)
      |> Enum.into(%{})

    contact_widgets = fetch_all("Contact Widgets") |> process_contact_widgets()
    questions = fetch_all("Custom Questions") |> process_question_widgets()

    ~m(listings scripts contact_widgets questions)a
  end

  defp fetch_all(for_table) do
    %{body: body} =
      HTTPotion.get(
        "https://api.airtable.com/v0/#{base()}/#{URI.encode(for_table)}",
        headers: [
          Authorization: "Bearer #{key()}"
        ],
        query: [view: "Grid view"],
        timeout: :infinity
      )

    decoded = Poison.decode!(body)

    if Map.has_key?(decoded, "offset"),
      do: fetch_all(for_table, decoded["records"], decoded["offset"]),
      else: decoded["records"]
  end

  defp fetch_all(for_table, records, offset) do
    %{body: body} =
      HTTPotion.get(
        "https://api.airtable.com/v0/#{base()}/#{URI.encode(for_table)}",
        headers: [
          Authorization: "Bearer #{key()}"
        ],
        query: [offset: offset, view: "Grid view"],
        timeout: :infinity
      )

    decoded = Poison.decode!(body)
    new_records = decoded["records"]
    all_records = Enum.concat(records, new_records)

    if Map.has_key?(decoded, "offset"),
      do: fetch_all(for_table, all_records, decoded["offset"]),
      else: all_records
  end

  defp process_listings(records) do
    records
    |> Enum.filter(fn ~m(fields) -> Map.has_key?(fields, "Reference Name") end)
    |> Enum.map(fn ~m(fields) ->
      {
        slugify(fields["Reference Name"]),
        %{
          "use_match" => Regex.compile!(fields["Account Regular Expression"]),
          "service_ids" => nil_safe_split(fields["Service Ids"]),
          "reference_name" => fields["Reference Name"],
          "event_slug" => fields["Event Slug"],
          "ready_html" => fields["Ready HTML"],
          "not_ready_html" => fields["Not Ready HTML"],
          "service_name" => fields["Service Name"],
          "events_filter" => fields["Events Filter"]
        }
      }
    end)
    |> Enum.into(%{})
  end

  defp process_script(records) do
    records
    |> Enum.map(fn ~m(fields id) ->
      %{
        "id" => id,
        "reference_name" => fields["Reference Name"],
        "display_name" => fields["Display Name"],
        "order" => fields["Order"],
        "contents" => fields["Contents"],
        "contact_widget" => first_or_nil(fields["Contact Widget"]),
        "event_widget" => fields["Event Widget"],
        "questions" => fields["Questions"],
        "form_label" => fields["Form Label"],
        "color" => fields["Button Color"],
        "children" => fields["Nested Options"],
        "track_clicks" => fields["Track Clicks"]
      }
    end)
    |> Enum.into([])
  end

  defp first_or_nil(nil), do: nil
  defp first_or_nil(l) when is_list(l), do: List.first(l)

  defp process_contact_widgets(records) do
    records
    |> Enum.map(fn ~m(fields id) ->
      {id,
       %{
         "content" => fields["Content"],
         "image" => fields["Image"]
       }}
    end)
    |> Enum.into(%{})
  end

  defp process_question_widgets(records) do
    records
    |> Enum.map(fn ~m(fields id) ->
      {id,
       %{
         "name" => fields["Name"],
         "label" => fields["Label"],
         "type" =>
           %{
             "Long text" => "textarea",
             "Short text" => "text",
             "Radio" => "radio",
             "Checkbox" => "checkbox"
           }[fields["Type"]],
         "options" => nil_safe_split(fields["Options"])
       }}
    end)
    |> Enum.into(%{})
  end

  def slugify(reference_name) do
    reference_name
    |> String.downcase()
    |> String.replace(" ", "-")
    |> String.replace("''", "")
  end

  def nil_safe_split(nil), do: nil
  def nil_safe_split(options), do: String.split(options, "\n") |> Enum.map(&String.trim/1)
end
