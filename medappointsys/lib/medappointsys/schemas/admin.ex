defmodule Medappointsys.Schemas.Admin do
  use Ecto.Schema

  schema "admins" do
    field :email, :string
    field :password, :string, default: "123"
    field :firstname, :string, default: ""
    field :lastname, :string, default: ""
  end
end
