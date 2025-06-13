defmodule Mix.Tasks.TowerSlack.Task.InstallTest do
  use ExUnit.Case, async: true
  import Igniter.Test

  test "generates everything from scratch" do
    test_project()
    |> Igniter.compose_task("tower_slack.install", [])
    |> assert_creates("config/config.exs", """
    import Config
    config :tower, reporters: [TowerSlack]
    """)
    |> assert_creates("config/runtime.exs", """
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
        "config/config.exs" => """
        import Config

        config :tower, reporters: [TowerEmail]
        """,
        "config/runtime.exs" => """
        import Config
        """
      }
    )
    |> Igniter.compose_task("tower_slack.install", [])
    |> assert_has_patch("config/config.exs", """
    |import Config
    |
    - |config :tower, reporters: [TowerEmail]
    + |config :tower, reporters: [TowerEmail, TowerSlack]
    """)
    |> assert_has_patch("config/runtime.exs", """
    |import Config
    |
    + |config :tower_slack,
    + |  otp_app: :test,
    + |  webhook_url: System.get_env("TOWER_SLACK_WEBHOOK_URL"),
    + |  environment: System.get_env("DEPLOYMENT_ENV", to_string(config_env()))
    """)
  end
end
