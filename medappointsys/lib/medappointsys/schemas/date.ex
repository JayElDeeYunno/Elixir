defmodule Medappointsys.Schemas.Date do
  use Ecto.Schema

  schema "dates" do
    field :date, :date

    has_many :appointments, Medappointsys.Schemas.Appointment
  end
end
