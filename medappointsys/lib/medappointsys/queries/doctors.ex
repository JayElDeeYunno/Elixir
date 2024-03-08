defmodule Medappointsys.Queries.Doctors do
  import Ecto.Query
  alias MedAppointSys.Repo
  alias Medappointsys.Schemas.Doctor
  alias Medappointsys.Schemas.Appointment
  alias Medappointsys.Schemas.Patient
  alias Medappointsys.Schemas.DoctorTimerange
  alias Medappointsys.Schemas.Timerange
  alias Medappointsys.Schemas.Unavailability
  alias Medappointsys.Queries.Timeranges

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

  def delete_doctor_timerange(doctor_id, timerange_id) do
    # Fetch the DoctorTimerange struct
    struct = Repo.get_by(DoctorTimerange, doctor_id: doctor_id, timerange_id: timerange_id)

    # Check if the struct exists
    case struct do
      nil ->
        {:error, "Doctor timerange not found."}

      _ ->
        # Build a changeset for deletion
        changeset = DoctorTimerange.changeset(struct, %{})

        # Delete the doctor timerange using the changeset
        case Repo.delete(changeset) do
          {:ok, _deleted} ->
            {:ok, "Timerange deleted successfully."}

          {:error, _reason} ->
            {:error, "Failed to delete timerange."}
        end
    end
  end

  def delete_doctor_timerange(doctor_timerange) do
      # Build a changeset for deletion
      changeset = DoctorTimerange.changeset(doctor_timerange, %{})

      # Delete the doctor timerange using the changeset
      case Repo.delete(changeset) do
        {:ok, _deleted} ->
          {:ok, "Timerange deleted successfully."}

        {:error, _reason} ->
          {:error, "Failed to delete timerange."}
      end

  end

  def get_doctor_timeranges(doctor_id) do
    Repo.all(
      from dtr in DoctorTimerange,
      join: t in Timerange,
      on: dtr.timerange_id == t.id,
      where: dtr.doctor_id == ^doctor_id,
      preload: [:doctor, :timerange]
    )
  end

  def get_available_timeranges(current_timeranges) do
    all_timeranges = Timeranges.list_timeranges()
    current_timerange_ids = Enum.map(current_timeranges, & &1.id)

    Enum.filter(all_timeranges, fn timerange ->
      timerange.id not in current_timerange_ids
    end)
  end

  def list_unavailabilities(doctor_id) do
    query =
      from(d in Unavailability,
        where: d.doctor_id == ^doctor_id,
        select: d,
        preload: [:date]
      )
    Repo.all(query)
  end

  def create_unavailability(attrs \\ %{}) do
    %Unavailability{}
    |> Unavailability.changeset(attrs)
    |> Repo.insert()
  end

  def delete_unavailability(%Unavailability{} = unavailability) do
    case Repo.delete(unavailability) do
      {:ok, _} ->
        {:ok, "Unavailability deleted successfully"}

      {:error, _} ->
        {:error, "Failed to delete unavailability."}
    end
  end
end
