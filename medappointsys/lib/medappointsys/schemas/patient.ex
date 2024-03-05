defmodule Medappointsys.Schemas.Patient do
  use Ecto.Schema
  import Ecto.Changeset

  schema "patients" do
    field :email, :string
    field :password, :string, default: ""
    field :firstname, :string, default: ""
    field :lastname, :string, default: ""
    field :gender, :string, default: ""
    field :age, :integer, default: 0
    field :address, :string, default: ""
    field :contact_num, :string, default: ""

    has_many :appointments, Medappointsys.Schemas.Appointment

    timestamps()
  end

  def changeset(struct, params) do
    struct
    |> cast(params, [:email, :password, :firstname, :lastname, :gender, :age, :address, :contact_num])
    |> validate_required([:email])
    |> validate_length(:email, min: 2)
  end
end
