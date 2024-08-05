defmodule TowerSlack.MixProject do
  use Mix.Project

  def project do
    [
      app: :tower_slack,
      version: "0.1.0",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps()
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
      {:tower, github: "mimiquate/tower", branch: "level"},
      {:jason, "~> 1.4"},

      # Test
      {:bypass, "~> 2.1", only: :test}
    ]
  end
end
