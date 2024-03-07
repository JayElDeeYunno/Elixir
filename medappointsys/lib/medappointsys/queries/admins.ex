defmodule Medappointsys.Queries.Admins do
  import Ecto.Query
  alias Medappointsys.Queries.{Admins, Doctors, Patients}
  alias MedAppointSys.Repo
  alias Medappointsys.Schemas.{Admin, Doctor, Patient}
  #
  def list_admins do
    Repo.all(Admin)
  end

  def get_admin!(id), do: Repo.get!(Admin, id)

  #
  # -------------------------------------------------------------------------------------------------------------#
  def find_admin(email) do
    case Repo.get_by(Admin, email: email) do
      nil -> nil
      admin -> {admin, :admins}
    end
  end

  def match_credentials(email) do
    doctorCredentials = Repo.all(from d in Doctor, select: [d.email])
    adminCredentials = Repo.all(from a in Admin, select: [a.email])
    patientCredentials = Repo.all(from p in Patient, select: [p.email])

    doctorCredentials ++ adminCredentials ++ patientCredentials
    |> Enum.flat_map(fn x -> x end)
    |> Enum.member?(email)

  end

  def retrieve_info(email) do
      [
        find_admin(email),
        Doctors.find_doctor(email),
        Patients.find_patient(email)
      ]
      |> Enum.find(&not is_nil(&1))
  end
end
