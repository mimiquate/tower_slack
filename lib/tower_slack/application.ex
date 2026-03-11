defmodule TowerSlack.Application do
  use Application

  def start(_type, _args) do
    Supervisor.start_link(
      [
        {
          TowerSlack.KeyCounter,
          reset_window: Application.fetch_env!(:tower_slack, :ignore_duplicates_window)
        }
      ],
      strategy: :one_for_one,
      name: TowerSlack.Supervisor
    )
  end
end
