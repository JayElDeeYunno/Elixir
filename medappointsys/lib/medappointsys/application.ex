defmodule Medappointsys.Application do

  @moduledoc false
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      MedAppointSys.Repo
    ]

    opts = [strategy: :one_for_one, name: Medappointsys.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
