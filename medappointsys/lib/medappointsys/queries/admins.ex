defmodule Medappointsys.Queries.Admins do
  import Ecto.Query
  alias Medappointsys.Queries.Appointments
  alias Medappointsys.Queries.{Admins, Doctors, Patients, Dates, Timeranges}
  alias MedAppointSys.Repo
  alias Medappointsys.Schemas.{Admin, Doctor, Patient}
  #
  def list_admins do
    Repo.all(Admin)
  end

  def get_admin!(id), do: Repo.get!(Admin, id)

  def create_admin(attrs \\ %{}) do
    case %Admin{}
    |> Admin.changeset(attrs)
    |> Repo.insert() do
      {:error, changeset} -> IO.puts("Register failed")
                              {:error, changeset}

      {:ok, createdAdmin} -> IO.puts("Register sucess")
                              {:ok, createdAdmin}
    end
  end
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

    # -------------------------------------------------------------------------------------------------------------#

    def add_doctor_presets() do
      Doctors.create_doctor(%{email: "jrtoyoda@example.com",
      password: "123",
      firstname: "Jaen Rafael",
      lastname: "Toyoda",
      gender: "Male",
      age: 23,
      address: "Bangkal",
      contact_num: "09123456789",
      specialization: "Rizzology"})

      Doctors.create_doctor(%{email: "jsmith@example.com",
      password: "456",
      firstname: "John",
      lastname: "Smith",
      gender: "Male",
      age: 35,
      address: "Downtown",
      contact_num: "09876543210",
      specialization: "Cardiology"})

      Doctors.create_doctor(%{email: "glmartinez@example.com",
      password: "def",
      firstname: "Grace",
      lastname: "Martinez",
      gender: "Female",
      age: 32,
      address: "Suburbia",
      contact_num: "05432109876",
      specialization: "Oncology"})

      Doctors.create_doctor(%{email: "michaelj@example.com",
      password: "ghi",
      firstname: "Michael",
      lastname: "Johnson",
      gender: "Male",
      age: 45,
      address: "Rural",
      contact_num: "04321098765",
      specialization: "Neurology"})

      Doctors.create_doctor(%{email: "sarahbrown@example.com",
      password: "jkl",
      firstname: "Sarah",
      lastname: "Brown",
      gender: "Female",
      age: 30,
      address: "Beachside",
      contact_num: "03210987654",
      specialization: "Orthopedics"})
    end

    def addPatientPresets() do
    Patients.create_patient(%{email: "jdelacruz@example.com",
    password: "123",
    firstname: "Juan",
    lastname: "Dela Cruz",
    gender: "Male",
    age: 19,
    address: "Davao",
    contact_num: "09871238142"})

    Patients.create_patient(%{email: "rfernandez@example.com",
    password: "789",
    firstname: "Ramon",
    lastname: "Fernandez",
    gender: "Male",
    age: 32,
    address: "Cebu",
    contact_num: "06543210987"})

    Patients.create_patient(%{email: "mmendoza@example.com",
    password: "456",
    firstname: "Maria",
    lastname: "Mendoza",
    gender: "Female",
    age: 25,
    address: "Manila",
    contact_num: "07654321098"})

    Patients.create_patient(%{email: "clim@example.com",
    password: "abc",
    firstname: "Catherine",
    lastname: "Lim",
    gender: "Female",
    age: 28,
    address: "Baguio",
    contact_num: "05432109876"})

    Patients.create_patient(%{email: "mperez@example.com",
    password: "def",
    firstname: "Miguel",
    lastname: "Perez",
    gender: "Male",
    age: 22,
    address: "Iloilo",
    contact_num: "04321098765"})
    end

    def addAppointmentPresets() do
    Appointments.create_appointment(%{status: "Pending",
    reason: "Sick",
    patient_id: 1,
    doctor_id: 1,
    date_id: 1,
    timerange_id: 1})

    Appointments.create_appointment(%{status: "Pending",
    reason: "Allergies",
    patient_id: 1,
    doctor_id: 2,
    date_id: 2,
    timerange_id: 2})

    Appointments.create_appointment(%{status: "Pending",
    reason: "Colds",
    patient_id: 1,
    doctor_id: 3,
    date_id: 2,
    timerange_id: 4})

    Appointments.create_appointment(%{status: "Pending",
    reason: "Cramps",
    patient_id: 2,
    doctor_id: 3,
    date_id: 2,
    timerange_id: 3})

    Appointments.create_appointment(%{status: "Pending",
    reason: "Allergies",
    patient_id: 2,
    doctor_id: 1,
    date_id: 2,
    timerange_id: 1})
    end


    def addAdminPresets() do

    Admins.create_admin(%{email: "admin@example.com",
    password: "123",
    firstname: "admin",
    lastname: "test"
    })

    Admins.create_admin(%{email: "ceo@example.com",
    password: "123",
    firstname: "ceo",
    lastname: "test"
    })


    Admins.create_admin(%{email: "author@example.com",
    password: "123",
    firstname: "author",
    lastname: "test"
    })


    end

    def addDatesPresets() do
    Dates.create_date(%{date: ~D[2024-03-07]
    })
    Dates.create_date(%{date: ~D[2024-03-08]
    })
    Dates.create_date(%{date: ~D[2024-03-09]
    })
    Dates.create_date(%{date: ~D[2024-03-10]
    })
    Dates.create_date(%{date: ~D[2024-03-11]
    })
    Dates.create_date(%{date: ~D[2024-03-12]
    })
    Dates.create_date(%{date: ~D[2024-03-13]
    })
    Dates.create_date(%{date: ~D[2024-03-14]
    })
    Dates.create_date(%{date: ~D[2024-03-15]
    })
    Dates.create_date(%{date: ~D[2024-03-16]
    })
    Dates.create_date(%{date: ~D[2024-03-17]
    })
    Dates.create_date(%{date: ~D[2024-03-18]
    })
    Dates.create_date(%{date: ~D[2024-03-19]
    })
    end

    def addDoctorsTimerangesPresets() do
    Doctors.add_doctor_timerange(%{doctor_id: 1,
    timerange_id: 1})
    Doctors.add_doctor_timerange(%{doctor_id: 1,
    timerange_id: 2})
    Doctors.add_doctor_timerange(%{doctor_id: 1,
    timerange_id: 3})
    Doctors.add_doctor_timerange(%{doctor_id: 1,
    timerange_id: 4})
    Doctors.add_doctor_timerange(%{doctor_id: 1,
    timerange_id: 5})

    Doctors.add_doctor_timerange(%{doctor_id: 2,
    timerange_id: 1})
    Doctors.add_doctor_timerange(%{doctor_id: 2,
    timerange_id: 2})
    Doctors.add_doctor_timerange(%{doctor_id: 2,
    timerange_id: 3})
    Doctors.add_doctor_timerange(%{doctor_id: 2,
    timerange_id: 4})
    Doctors.add_doctor_timerange(%{doctor_id: 2,
    timerange_id: 5})

    Doctors.add_doctor_timerange(%{doctor_id: 3,
    timerange_id: 1})
    Doctors.add_doctor_timerange(%{doctor_id: 3,
    timerange_id: 2})
    Doctors.add_doctor_timerange(%{doctor_id: 3,
    timerange_id: 3})
    Doctors.add_doctor_timerange(%{doctor_id: 3,
    timerange_id: 4})
    Doctors.add_doctor_timerange(%{doctor_id: 3,
    timerange_id: 5})
    end

    def addTimerangesPresets() do
    Timeranges.create_timerange(%{start_time: ~T[10:00:00],
    end_time: ~T[11:00:00]})

    Timeranges.create_timerange(%{start_time: ~T[11:00:00],
    end_time: ~T[12:00:00]})

    Timeranges.create_timerange(%{start_time: ~T[12:00:00],
    end_time: ~T[13:00:00]})

    Timeranges.create_timerange(%{start_time: ~T[13:00:00],
    end_time: ~T[14:00:00]})

    Timeranges.create_timerange(%{start_time: ~T[14:00:00],
    end_time: ~T[15:00:00]})
    end

    # def addUnavailabilitiesPresets() do

    # end
end
