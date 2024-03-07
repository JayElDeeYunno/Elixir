defmodule Medappointsys.Schemas.DoctorTimerange do
  use Ecto.Schema

  schema "doctors_timeranges" do
    belongs_to :doctor, Medappointsys.Schemas.Doctor
    belongs_to :timerange, Medappointsys.Schemas.Timerange
  end
end
