defmodule MedAppointSys.Repo.Migrations.CreateTimeranges do
  use Ecto.Migration

  def change do
    create table(:timeranges) do
      add :start_time, :time, null: false
      add :end_time, :time, null: false
    end
  end
end
