defmodule AgentDesktop.Scripts do
  alias AgentDesktop.{AirtableConfig}
  import ShortMaps

  def script_for(account_number) do
    ~m(listings scripts)a = AirtableConfig.get_all()

    match =
      Enum.filter(listings, fn {slug, ~m(use_match)} ->
        Regex.match?(use_match, account_number)
      end)
      |> List.first()

    case match do
      {slug, ~m(reference_name)} -> %{answers: scripts[slug], name: reference_name}
      nil -> nil
    end
  end
end
