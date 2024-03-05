defmodule MedAppointSys.Repo.Migrations.CreateAdmins do
  use Ecto.Migration

  def change do
    create table(:admins) do
      add :email, :string, null: false
      add :password, :string, null: false, default: "123"
      add :firstname, :string, default: ""
      add :lastname, :string, default: ""

      timestamps()
    end
  end
end
