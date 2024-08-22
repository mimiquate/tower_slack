defmodule TowerSlack.MixProject do
  use Mix.Project

  @description "A simple post-to-Slack reporter for Tower error handler"
  @source_url "https://github.com/mimiquate/tower_slack"
  @version "0.4.0"

  def project do
    [
      app: :tower_slack,
      description: @description,
      version: @version,
      elixir: "~> 1.15",
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
      extra_applications: [:logger, :public_key, :inets]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:tower, "~> 0.5.0"},
      {:jason, "~> 1.4"},

      # Dev
      {:ex_doc, "~> 0.34.2", only: :dev, runtime: false},

      # Test
      {:bypass, "~> 2.1", only: :test}
    ]
  end

  defp package do
    [
      licenses: ["Apache-2.0"],
      links: %{
        "GitHub" => @source_url
      }
    ]
  end

  defp docs do
    [
      main: "readme",
      extras: ["README.md"]
    ]
  end
end
