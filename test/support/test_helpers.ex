defmodule TowerSlack.TestHelpers do
  @moduledoc false

  def run_db_migration(direction) do
    Ecto.Migrator.run(
      TowerSlack.TestRepo,
      [{1, TowerSlack.TestRepo.Migrations.CreateTowerWebDB}],
      direction,
      all: true
    )
  end
end
