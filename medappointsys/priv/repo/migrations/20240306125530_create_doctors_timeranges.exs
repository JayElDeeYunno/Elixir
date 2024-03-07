defmodule MedAppointSys.Repo.Migrations.CreateDoctorsTimeranges do
  use Ecto.Migration

  def change do
    create table(:doctors_timeranges) do
      add :doctor_id, references(:doctors)
      add :timerange_id, references(:timeranges)
    end

    # create unique_index(:doctors_timeranges, [:doctor_id, :timerange_id])
  end
end
