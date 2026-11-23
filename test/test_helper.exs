{:ok, _} = TowerSlack.TestRepo.start_link()
TowerSlack.TestHelpers.run_db_migration(:up)

ExUnit.start()

Application.put_env(:tower_slack, :otp_app, :tower_slack)
Application.put_env(:tower_slack, :environment, :test)

Ecto.Adapters.SQL.Sandbox.mode(TowerSlack.TestRepo, :manual)
