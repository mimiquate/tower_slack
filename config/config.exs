import Config

config :tower_web, pruner: false, repo: TowerSlack.TestRepo

config :tower_slack,
  ecto_repos: [TowerSlack.TestRepo]

config :tower_slack, TowerSlack.TestRepo,
  pool: Ecto.Adapters.SQL.Sandbox,
  priv: "test/support/tower_web_db",
  url: System.get_env("POSTGRES_URL") || "postgres://localhost:5432/tower_slack_test",
  log: false
