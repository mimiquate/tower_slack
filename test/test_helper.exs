ExUnit.start()

Application.put_env(:tower_slack, :otp_app, :tower_slack)
Application.put_env(:tower_slack, :environment, :test)
