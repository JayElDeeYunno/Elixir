defmodule Medappointsys.Queries.Patients do
  import Ecto.Query
  alias MedAppointSys.Repo
  alias Medappointsys.Schemas.Patient

  def list_patients do
    Repo.all(Patient)
  end

  def get_patient!(id), do: Repo.get!(Patient, id)

  def create_patient(attrs \\ %{}) do
    %Patient{}
    |> Patient.changeset(attrs)
    |> Repo.insert()
  end

  def update_patient(%Patient{} = patient, attrs) do
    patient
    |> Patient.changeset(attrs)
    |> Repo.update()
  end

  def delete_patient(%Patient{} = patient) do
    Repo.delete(patient)
  end

  def change_patient(%Patient{} = patient, attrs \\ %{}) do
    Patient.changeset(patient, attrs)
  end

  # -------------------------------------------------------------------------------------------------------------#

  @spec find_patient(any(), any(), any(), any(), any(), integer(), any(), any()) :: any()
  def find_patient(email, password, firstname, lastname, gender, age, address, contact_num) do
    Repo.get_by(Patient, email: email, password: password, firstname: firstname, lastname: lastname,
    gender: gender, age: age, address: address, contact_num: contact_num)
  end

  def find_patient(email, password) do
    Repo.get_by(Patient, email: email, password: password)
  end

end
