defmodule TowerSlack.TestRepo do
  @moduledoc false

  use Ecto.Repo,
    otp_app: :tower_slack,
    adapter: Ecto.Adapters.Postgres
end
