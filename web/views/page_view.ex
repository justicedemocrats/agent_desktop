defmodule AgentDesktop.PageView do
  use AgentDesktop.Web, :view

  @defaults %{
    "first" => "First",
    "last" => "Last",
    "phone" => "555-555-5555"
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
    rand_id =
      :crypto.strong_rand_bytes(10)
      |> Base.url_encode64()
      |> binary_part(0, 10)
      |> String.split("")
      |> Enum.filter(&(Regex.run(~r/[A-Zz-z]/, &1) != nil))
      |> Enum.join("")

    data = Map.merge(@defaults, voter)

    ~s[
      <div id="#{rand_id}"> </div>
      <script>
        var template = `#{base_contents}`;
        var rendered = Mustache.render(template, JSON.parse('#{Poison.encode!(data)}'));
        document.getElementById("#{rand_id}").parentNode.innerHTML = rendered;
      </script>
    ]
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
  end
end
