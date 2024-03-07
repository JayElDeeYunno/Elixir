defmodule Medappointsys.Queries.Doctors do
  import Ecto.Query
  alias MedAppointSys.Repo
  alias Medappointsys.Schemas.{Doctor, Appointment, Patient, Date, DoctorTimerange, Timerange}

  def list_doctors do
    Repo.all(Doctor)
  end

  def get_doctor!(id), do: Repo.get!(Doctor, id)

  @spec create_doctor() :: {:error, any()} | {:ok, any()}
  def create_doctor(attrs \\ %{}) do
    case %Doctor{}
    |> Doctor.changeset(attrs)
    |> Repo.insert() do
      {:error, changeset} -> IO.puts("Register failed")
                                {:error, changeset}

      {:ok, createdDoctor} -> IO.puts("Register success")
                                {:ok, createdDoctor}
    end
  end

  def update_doctor(%Doctor{} = doctor, attrs) do
    case doctor
    |> Doctor.changeset(attrs)
    |> Repo.update() do
      {:error, changeset} -> IO.puts("Update failed")
                              {:error, changeset}

      {:ok, updatedDoctor} -> IO.puts("Update success")
                                {:ok, updatedDoctor}
    end
  end

  def update_doctor(%Doctor{} = doctor, field, value) do
    case doctor
    |> Doctor.changeset(%{field => value})
    |> Repo.update() do
      {:error, changeset} -> IO.puts("Update failed")
                              {:error, changeset}

      {:ok, updatedPatient} -> IO.puts("Update success")
                                {:ok, updatedPatient}
    end
  end

  def delete_doctor(%Doctor{} = doctor) do
    case Repo.delete(doctor) do
      {:error, changeset} -> IO.puts("Delete failed")
                                {:error, changeset}

      {:ok, deletedDoctor} -> IO.puts("Delete success")
                                  {:ok, deletedDoctor}
    end
  end

  # -------------------------------------------------------------------------------------------------------------#
  def find_doctor(email, password, firstname, lastname, gender, age, address, contact_num, specialization) do
    Repo.get_by(Doctor, email: email, password: password, firstname: firstname, lastname: lastname,
    gender: gender, age: age, address: address, contact_num: contact_num, specialization: specialization)
  end

  def find_doctor(email) do

    case Repo.get_by(Doctor, email: email) do
      nil -> nil
      doctor -> {doctor, :doctors}
    end
  end

  def get_patients(selected_doctor) do
    query =
      from(a in Appointment,
        where: a.doctor_id == ^selected_doctor.id,
        join: p in Patient, on: a.patient_id == p.id,
        distinct: p.id,
        select: p)
    Repo.all(query)
  end

  def get_timeranges(selected_doctor) do
    query =
      from(dt in DoctorTimerange,
        where: dt.doctor_id == ^selected_doctor.id,
        join: t in Timerange, on: dt.timerange_id == t.id,
        select: t)
    Repo.all(query)
  end

  def add_doctor_timerange(attrs \\ %{}) do
    case %DoctorTimerange{}
    |> DoctorTimerange.changeset(attrs)
    |> Repo.insert() do
      {:error, changeset} -> IO.puts("Insert failed")
                                {:error, changeset}

      {:ok, createdDoctorTimeRange} -> IO.puts("Insert success")
                                {:ok, createdDoctorTimeRange}
    end
  end
end
