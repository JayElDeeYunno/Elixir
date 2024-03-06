defmodule Medappointsys.Queries.Patients do
  import Ecto.Query
  alias MedAppointSys.Repo
  alias Medappointsys.Schemas.Patient

  def list_patients do
    Repo.all(Patient)
  end

  def get_patient!(id), do: Repo.get!(Patient, id)

  def create_patient(attrs \\ %{}) do
    case %Patient{}
    |> Patient.changeset(attrs)
    |> Repo.insert() do
      {:error, changeset} -> IO.puts("Register failed")
                              {:error, changeset}

      {:ok, createdPatient} -> IO.puts("Register sucess")
                              {:ok, createdPatient}
    end
  end

  def update_patient(%Patient{} = patient, attrs) do
    case patient
    |> Patient.changeset(attrs)
    |> Repo.update() do
      {:error, changeset} -> IO.puts("Update failed")
                              {:error, changeset}
      {:ok, updatedPatient} -> IO.puts("Update success")
                                {:ok, updatedPatient}
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
    case Repo.delete(patient) do
      {:error, changeset} -> IO.puts("Delete failed")
                              {:error, changeset}
      {:ok, deletedPatient} -> IO.puts("Delete success")
                              {:ok, deletedPatient}
    end
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
