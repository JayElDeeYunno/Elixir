defmodule Medappointsys.Schemas.Unavailability do
  use Ecto.Schema
  import Ecto.Changeset

  schema "unavailabilities" do
    belongs_to :doctor, Medappointsys.Schemas.Doctor
    belongs_to :timerange, Medappointsys.Schemas.Timerange
    belongs_to :date, Medappointsys.Schemas.Date
  end

  def changeset(struct, params) do
    struct
    |> cast(params, [:doctor_id, :timerange_id, :date_id])
    |> validate_required([:doctor_id, :timerange_id, :date_id])
  end
end
