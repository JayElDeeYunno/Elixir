defmodule Medappointsys.Schemas.Date do
  use Ecto.Schema
  import Ecto.Changeset

  schema "dates" do
    field :date, :date

    has_many :appointments, Medappointsys.Schemas.Appointment

    many_to_many :timeranges_unavailabilities, Medappointsys.Schemas.Timerange, join_through: "unavailabilities"
    many_to_many :doctors_unavailabilities, Medappointsys.Schemas.Doctor, join_through: "unavailabilities"

    def changeset(date, attrs) do
      date
      |> cast(attrs, [:date])
      |> validate_required([:date])
    end
  end
end
