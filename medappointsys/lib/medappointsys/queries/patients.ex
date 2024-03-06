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
    case patient
    |> Patient.changeset(attrs)
    |> Repo.update() do
      {:error, changeset} -> {:error, changeset}

      {:ok, _updatedPatient} -> IO.puts("Update success")
    end
  end

  def update_patient(%Patient{} = patient, field, value) do
    case patient
    |> Patient.changeset(%{field => value})
    |> Repo.update() do
      {:error, changeset} -> IO.puts("Update failed")
                              {:error, changeset}

      {:ok, updatedPatient} -> IO.puts("Update success")
                                {:ok, updatedPatient}
    end
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
