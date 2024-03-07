defmodule MedAppointSys.Repo.Migrations.CreateUnavailability do
  use Ecto.Migration

  def change do
    create table(:unavailabilities) do
      add :doctor_id, references(:doctors)
      add :timerange_id, references(:timeranges)
      add :date_id, references(:dates)
    end

    # create unique_index(:unavailabilities, [:doctor_id, :timerange_id, :date_id])
  end
end
