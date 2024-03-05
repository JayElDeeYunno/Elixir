defmodule MedAppointSys.Repo.Migrations.CreateDates do
  use Ecto.Migration

  def change do
    create table(:dates) do
      add :date, :date, null: false
    end
  end
end
