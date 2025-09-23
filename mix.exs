defmodule TowerSlack.MixProject do
  use Mix.Project

  @description "Error tracking and reporting to Slack"
  @source_url "https://github.com/mimiquate/tower_slack"
  @changelog_url @source_url <> "/blob/-/CHANGELOG.md"
  @version "0.6.1"

  def project do
    [
      app: :tower_slack,
      description: @description,
      version: @version,
      elixir: "~> 1.15",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),

      # Docs
      name: "TowerSlack",
      source_url: @source_url,
      docs: docs()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {TowerSlack.Application, []},
      extra_applications: [:logger, :public_key, :inets]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:tower, "~> 0.7.1 or ~> 0.8.0", github: "mimiquate/tower"},

      # Optional
      {:igniter, "~> 0.6", optional: true},

      # Only needed for Elixir < 1.18
      {:jason, "~> 1.4", optional: true},

      # Dev
      {:blend, "~> 0.5.0", only: :dev},
      {:ex_doc, "~> 0.38.2", only: :dev, runtime: false},

      # Test
      {:bandit, "~> 1.5", only: :test},
      {:lasso, "~> 0.1.4", only: :test}
    ]
  end

  defp package do
    [
      licenses: ["Apache-2.0"],
      links: %{
        "GitHub" => @source_url,
        "Changelog" => @changelog_url
      }
    ]
  end

  defp docs do
    [
      main: "readme",
      extras: [
        "README.md": [title: "README"],
        "CHANGELOG.md": [title: "Changelog"]
      ]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]
end
