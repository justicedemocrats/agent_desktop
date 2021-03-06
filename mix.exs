defmodule AgentDesktop.Mixfile do
  use Mix.Project

  def project do
    [
      app: :agent_desktop,
      version: "0.0.1",
      elixir: "~> 1.4",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {AgentDesktop, []},
      extra_applications: [:logger]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "web", "test/support"]
  defp elixirc_paths(_), do: ["lib", "web"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.3.0-rc"},
      {:phoenix_pubsub, "~> 1.0"},
      {:phoenix_html, "~> 2.10"},
      {:phoenix_live_reload, "~> 1.0", only: :dev},
      {:gettext, "~> 0.11"},
      {:cowboy, "~> 1.0"},
      {:short_maps, "~> 0.1.2"},
      {:httpotion, "~> 3.1.0"},
      {:quantum, ">= 2.2.1"},
      {:distillery, "~> 1.5.0", runtime: false},
      {:ex_json_schema, "~> 0.5.4"},
      {:actionkit, git: "https://github.com/justicedemocrats/actionkit_ex.git"},
      {:mongodb, "~> 0.4.3"},
      {:nimble_csv, "~> 0.3"}
    ]
  end
end
