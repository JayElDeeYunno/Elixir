defmodule Medappointsys.Queries.Dates do
  import Ecto.Query
  alias MedAppointSys.Repo
  alias Medappointsys.Schemas.Date

  def list_dates do
    Repo.all(Date)
  end

  def get_date!(id), do: Repo.get!(Date, id)

  def create_date(attrs \\ %{}) do
    %Date{}
    |> Date.changeset(attrs)
    |> Repo.insert()
  end

  def date_exists?(date) do
    from(d in Date, where: d.date == ^date)
    |> Repo.exists?()
  end

  def get_date_by_date(date) do
    Repo.get_by(Date, date: date)
  end
end
