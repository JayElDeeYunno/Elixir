defmodule Medappointsys.Schemas.Timerange do
  use Ecto.Schema
  import Ecto.Changeset

  schema "timeranges" do
    field :start_time, :time
    field :end_time, :time

    has_many :appointments, Medappointsys.Schemas.Appointment

    many_to_many :doctors, Medappointsys.Schemas.Doctor, join_through: "doctors_timeranges"

    many_to_many :doctors_unavailabilities, Medappointsys.Schemas.Doctor, join_through: "unavailabilities"
    many_to_many :dates_unavailabilities, Medappointsys.Schemas.Date, join_through: "unavailabilities"
  end

  def changeset(struct, params) do
    struct
    |> cast(params, [:start_time, :end_time])
    |> validate_required([:start_time, :end_time])
  end
end
