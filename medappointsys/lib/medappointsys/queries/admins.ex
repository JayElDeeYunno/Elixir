defmodule Medappointsys.Queries.Admins do
  import Ecto.Query
  alias MedAppointSys.Repo
  alias Medappointsys.Schemas.Admin

  def list_admins do
    Repo.all(Admin)
  end

  def get_admin!(id), do: Repo.get!(Admin, id)

  def create_admin(attrs \\ %{}) do
    %Admin{}
    |> Admin.changeset(attrs)
    |> Repo.insert()
  end

  def update_admin(%Admin{} = admin, attrs) do
    admin
    |> Admin.changeset(attrs)
    |> Repo.update()
  end

  def delete_admin(%Admin{} = admin) do
    Repo.delete(admin)
  end

  def change_admin(%Admin{} = admin, attrs \\ %{}) do
    Admin.changeset(admin, attrs)
  end

  # -------------------------------------------------------------------------------------------------------------#
  def find_admin(email, password) do
    Repo.get_by(Admin, email: email, password: password)
  end

end
