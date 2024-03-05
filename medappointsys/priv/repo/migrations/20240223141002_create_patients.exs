defmodule MedAppointSys.Repo.Migrations.CreatePatients do
  use Ecto.Migration

  def change do
    create table(:patients) do
      add :email, :string, null: false
      add :password, :string, null: false, default: "123"
      add :firstname, :string, default: ""
      add :lastname, :string, default: ""
      add :gender, :string, default: ""
      add :age, :integer, default: 0
      add :address, :string, default: ""
      add :contact_num, :string, default: ""

      timestamps()
    end
  end
end
