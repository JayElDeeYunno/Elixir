defmodule Medappointsys.Queries.Doctors do
  import Ecto.Query
  alias MedAppointSys.Repo
  alias Medappointsys.Schemas.Doctor
  alias Medappointsys.Schemas.Appointment
  alias Medappointsys.Schemas.Patient
  alias Medappointsys.Schemas.Date
  alias Medappointsys.Schemas.DoctorTimerange
  alias Medappointsys.Schemas.Timerange

  def list_doctors do
    Repo.all(Doctor)
  end

  # def list_doctors_by_id do
  #   Repo.all(
  #     from d in Doctor,
  #     select: [d.id]
  #   )
  #   |> Enum.flat_map(fn x -> x end)
  # end

  def get_doctor!(id), do: Repo.get!(Doctor, id)

  def create_doctor(attrs \\ %{}) do
    %Doctor{}
    |> Doctor.changeset(attrs)
    |> Repo.insert()
  end

  def update_doctor(%Doctor{} = doctor, attrs) do
    doctor
    |> Doctor.changeset(attrs)
    |> Repo.update()
  end

  def delete_doctor(%Doctor{} = doctor) do
    Repo.delete(doctor)
  end

  def change_doctor(%Doctor{} = doctor, attrs \\ %{}) do
    Doctor.changeset(doctor, attrs)
  end

  # -------------------------------------------------------------------------------------------------------------#

  @spec find_doctor(any(), any(), any(), any(), any(), integer(), any(), any(), any()) :: any()
  def find_doctor(email, password, firstname, lastname, gender, age, address, contact_num, specialization) do
    Repo.get_by(Doctor, email: email, password: password, firstname: firstname, lastname: lastname,
    gender: gender, age: age, address: address, contact_num: contact_num, specialization: specialization)
  end

  def find_doctor(email, password) do
    Repo.get_by(Doctor, email: email, password: password)
  end

  def get_timeranges(selected_doctor) do
    query =
      from(dt in Medappointsys.Schemas.DoctorTimerange,
        where: dt.doctor_id == ^selected_doctor.id,
        join: t in Medappointsys.Schemas.Timerange, on: dt.timerange_id == t.id,
        select: t)
    Repo.all(query)
  end


  # -------------------------------------------------------------------------------------------------------------#

  # def get_admin!(id), do: Repo.get!(Admin, id)
end
