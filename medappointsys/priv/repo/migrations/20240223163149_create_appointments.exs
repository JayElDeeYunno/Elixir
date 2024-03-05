defmodule MedAppointSys.Repo.Migrations.CreateAppointments do
  use Ecto.Migration

  def change do
    create table(:appointments) do
      add :status, :string, default: ""
      add :reason, :string, default: ""

      add :doctor_id, references(:doctors)
      add :patient_id, references(:patients)
      add :date_id, references(:dates)
      add :timerange_id, references(:timeranges)

      timestamps()
    end
  end
end
