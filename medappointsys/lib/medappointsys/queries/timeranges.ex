defmodule Medappointsys.Queries.Timeranges do
  import Ecto.Query
  alias MedAppointSys.Repo
  alias Medappointsys.Schemas.TimeRange

  def list_timeranges do
    Repo.all(Timerange)
  end

  def get_timerange!(id), do: Repo.get!(Timerange, id)

end
