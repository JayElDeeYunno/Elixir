defmodule Medappointsys.Queries.Patients do
  import Ecto.Query
  alias Medappointsys.Schemas.Date
  alias Medappointsys.Queries.Appointments
  alias MedAppointSys.Repo
  alias Medappointsys.Schemas.{Patient, Timerange, Appointment, Doctor}
  alias Medappointsys.Schemas.Date
  alias Medappointsys.Main, as: Main
  #
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

  # -------------------------------------------------------------------------------------------------------------#

  def find_patient(email, password, firstname, lastname, gender, age, address, contact_num) do
    Repo.get_by(Patient, email: email, password: password, firstname: firstname, lastname: lastname,
    gender: gender, age: age, address: address, contact_num: contact_num)
  end

  def find_patient(email) do
    case Repo.get_by(Patient, email: email) do
      nil -> nil
      patient -> {patient, :patients}
    end
  end

  def check_time(date, timerange_id, filters) do
    Repo.all(
      from a in Appointment,
      join: d in Doctor,
      on: a.doctor_id == d.id,
      join: dt in Date,
      on: a.date_id == dt.id,
      join: t in Timerange,
      on: a.timerange_id == t.id,
      where: a.timerange_id == ^timerange_id and dt.date == ^date and a.status in ^filters,
      preload: [:doctor, :timerange, :date]
    ) |> case do
        [] -> {:ok, "The selected appointment period is free."}
        _ -> {:error, "The selected appointment is unavailable."}
      end
  end


end
