defmodule MedAppointSys.Repo.Migrations.CreateUnavailability do
  use Ecto.Migration

  def change do
    create table(:unavailabilities) do
      add :doctor_id, references(:doctors)
      add :date_id, references(:dates)
    end
  end
end
