defmodule MedAppointSys.Repo.Migrations.CreateDoctors do
  use Ecto.Migration

  def change do
    create table(:doctors) do
      add :email, :string, null: false
      add :password, :string, null: false, default: "123"
      add :firstname, :string, default: ""
      add :lastname, :string, default: ""
      add :gender, :string, default: ""
      add :age, :integer, default: 0
      add :address, :string, default: ""
      add :contact_num, :string, default: ""
      add :specialization, :string, default: "Pediatrics"

      timestamps()
    end
  end
end
