defmodule Medappointsys.Schemas.Timerange do
  use Ecto.Schema

  schema "timeranges" do
    field :start_time, :time
    field :end_time, :time

    has_many :appointments, Medappointsys.Schemas.Appointment
  end
end
