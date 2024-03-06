defmodule Medappointsys.Schemas.Appointment do
  alias Medappointsys.Schemas.{Patient, Doctor, Date, Timerange}
  use Ecto.Schema
  import Ecto.Changeset

  schema "appointments" do
    field :status, :string, default: ""
    field :reason, :string, default: ""

    belongs_to :patient, Patient
    belongs_to :doctor, Doctor
    belongs_to :date, Date
    belongs_to :timerange, Timerange

    timestamps()
  end

  @spec changeset(
          {map(), map()}
          | %{
              :__struct__ => atom() | %{:__changeset__ => map(), optional(any()) => any()},
              optional(atom()) => any()
            },
          :invalid | %{optional(:__struct__) => none(), optional(atom() | binary()) => any()}
        ) :: Ecto.Changeset.t()
  def changeset(struct, params) do
    struct
    |> cast(params, [:status, :reason, :patient_id, :doctor_id, :date_id, :timerange_id])
    |> validate_required([:reason])
    |> validate_length(:reason, min: 2)
  end
end
