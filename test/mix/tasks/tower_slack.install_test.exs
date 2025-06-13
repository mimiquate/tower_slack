defmodule Mix.Tasks.TowerSlack.Task.InstallTest do
  use ExUnit.Case, async: true
  import Igniter.Test

  test "generates everything from scratch" do
    test_project()
    |> Igniter.compose_task("tower_slack.install", [])
    |> assert_creates("config/prod.exs", """
    import Config
    config :tower, reporters: [TowerSlack]
    config :tower_slack, otp_app: :test
    """)
    |> assert_creates("config/release.exs", """
    import Config

    config :tower_slack,
      otp_app: :test,
      webhook_url: System.get_env("TOWER_SLACK_WEBHOOK_URL"),
      environment: System.get_env("DEPLOYMENT_ENV", to_string(config_env()))
    """)
  end

  test "modifies existing tower configs if available" do
    test_project(
      files: %{
        "config/prod.exs" => """
        import Config

        config :tower, reporters: [TowerEmail]
        """,
        "config/release.exs" => """
        import Config
        """
      }
    )
    |> Igniter.compose_task("tower_slack.install", [])
    |> assert_has_patch("config/prod.exs", """
    |import Config
    |
    - |config :tower, reporters: [TowerEmail]
    + |config :tower, reporters: [TowerEmail, TowerSlack]
    + |config :tower_slack, otp_app: :test
    """)
    |> assert_has_patch("config/release.exs", """
    |import Config
    |
    + |config :tower_slack,
    + |  otp_app: :test,
    + |  webhook_url: System.get_env("TOWER_SLACK_WEBHOOK_URL"),
    + |  environment: System.get_env("DEPLOYMENT_ENV", to_string(config_env()))
    """)
  end
end
