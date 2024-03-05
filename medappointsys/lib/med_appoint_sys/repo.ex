defmodule MedAppointSys.Repo do
  use Ecto.Repo,
    otp_app: :medappointsys,
    adapter: Ecto.Adapters.Postgres
end
