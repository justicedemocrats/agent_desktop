defmodule AgentDesktop.Scripts do
  alias AgentDesktop.{AirtableConfig}
  import ShortMaps

  def script_for(~m(account_id service_id))
      when is_binary(account_id) and is_binary(service_id) do
    ~m(listings scripts)a = AirtableConfig.get_all()

    match =
      Enum.filter(listings, fn {_slug, ~m(use_match service_ids)} ->
        case service_ids do
          nil -> Regex.match?(use_match, account_id)
          ids when is_list(ids) -> Enum.member?(ids, service_id)
        end
      end)
      |> List.first()

    case match do
      {slug, listing = ~m(reference_name)} ->
        %{answers: scripts[slug], name: reference_name, listing: listing}

      nil ->
        nil
    end
  end

  def script_for(account_number) do
    ~m(listings scripts)a = AirtableConfig.get_all()

    match =
      Enum.filter(listings, fn {_slug, ~m(use_match)} ->
        Regex.match?(use_match, account_number)
      end)
      |> List.first()

    case match do
      {slug, listing = ~m(reference_name)} ->
        %{answers: scripts[slug], name: reference_name, listing: listing}

      nil ->
        nil
    end
  end
end
