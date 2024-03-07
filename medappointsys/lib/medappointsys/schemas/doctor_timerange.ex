defmodule Medappointsys.Schemas.DoctorTimerange do
  use Ecto.Schema
  import Ecto.Changeset

  schema "doctors_timeranges" do
    belongs_to :doctor, Medappointsys.Schemas.Doctor
    belongs_to :timerange, Medappointsys.Schemas.Timerange
  end

  def changeset(struct, params) do
    struct
    |> cast(params, [:doctor_id, :timerange_id])
    |> validate_required([:doctor_id, :timerange_id])
  end
end
