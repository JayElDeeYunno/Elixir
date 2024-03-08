defmodule Medappointsys.Queries.Timeranges do
  alias MedAppointSys.Repo
  alias Medappointsys.Schemas.Timerange

  def list_timeranges do
    Repo.all(Timerange)
  end

  def get_timerange!(id), do: Repo.get!(Timerange, id)

  def create_timerange(attrs \\ %{}) do
    %Timerange{}
    |> Timerange.changeset(attrs)
    |> Repo.insert()
  end
end
