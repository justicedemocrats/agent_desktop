defmodule AgentDesktop.PageView do
  use AgentDesktop.Web, :view
  import ShortMaps

  @defaults %{
    "first" => "friend",
    "last" => "",
    "phone" => "",
    "extra_7" => "",
    "extra_13" => "",
    "extra_14" => ""
  }

  def top_contents(voter, answers) do
    get_top(answers)
    |> Map.get("contents", "")
    |> do_replacement(voter)
  end

  def answer_contents(voter, answer) do
    Map.get(answer, "contents", "")
    |> do_replacement(voter)
  end

  def sorted_answers_for("top", answers) do
    case get_top(answers)
         |> Map.get("children") do
      nil ->
        []

      children ->
        children
        |> Enum.map(&get_answer(answers, &1))
        |> Enum.sort_by(& &1["order"], &>=/2)
    end
  end

  def sorted_answers_for(answer, answers) do
    case Map.get(answer, "children") do
      nil ->
        []

      children ->
        children
        |> Enum.map(&get_answer(answers, &1))
        |> Enum.sort_by(& &1["order"], &>=/2)
    end
  end

  def do_replacement(nil, _) do
    ""
  end

  def do_replacement(base_contents, voter) do
    Enum.reduce(~w(first last phone extra_7 extra_13 extra_14), base_contents, fn replacement, acc ->
      replacement_regex = Regex.compile!("{{[^(}{})]*#{replacement}[^(}{})]*}}")
      replacement_text = Map.get(voter, replacement, @defaults[replacement])
      String.replace(acc, replacement_regex, replacement_text, global: true)
    end)
  end

  def get_top(answers) do
    answers
    |> Enum.filter(&(&1["display_name"] == "TOP"))
    |> List.first()
  end

  def get_answer(answers, id) do
    answers
    |> Enum.filter(&(&1["id"] == id))
    |> List.first()
  end

  def non_top_answers(answers) do
    answers
    |> Enum.reject(&(&1["display_name"] == "TOP"))
  end

  def get_widget_contents(widget_id) do
    AgentDesktop.AirtableConfig.get_all().contact_widgets
    |> get_in([widget_id, "content"])
    |> String.replace("\n", "<br/>", global: true)
  end

  def namify(text) do
    text
    |> String.downcase()
    |> String.replace(" ", "_")
  end

  def questions_for(question_ids) do
    questions = AgentDesktop.AirtableConfig.get_all().questions

    Enum.map(question_ids, &Map.get(questions, &1))
    |> IO.inspect()
  end
end
