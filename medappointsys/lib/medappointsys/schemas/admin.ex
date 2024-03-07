defmodule Medappointsys.Schemas.Admin do
  use Ecto.Schema
  import Ecto.Changeset

  schema "admins" do
    field :email, :string
    field :password, :string, default: "123"
    field :firstname, :string, default: ""
    field :lastname, :string, default: ""

    timestamps()
  end

  def changeset(struct, params) do
    struct
    |> cast(params, [:email, :password, :firstname, :lastname])
    |> validate_required([:email, :password, :firstname, :lastname])
    |> validate_length(:password, min: 3)
  end
end
