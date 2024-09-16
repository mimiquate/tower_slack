defmodule TowerSlack.Application do
  use Application

  def start(_type, _args) do
    Supervisor.start_link(
      [
        TowerSlack.KeyCounter
      ],
      strategy: :one_for_one,
      name: TowerSlack.Supervisor
    )
  end
end
