defmodule Medappointsys.Schemas.Date do
  use Ecto.Schema

  schema "dates" do
    field :date, :date

    has_many :appointments, Medappointsys.Schemas.Appointment

    many_to_many :timeranges_unavailabilities, Medappointsys.Schemas.Timerange, join_through: "unavailabilities"
    many_to_many :doctors_unavailabilities, Medappointsys.Schemas.Doctor, join_through: "unavailabilities"
  end
end
