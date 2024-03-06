defmodule Medappointsys.Adminlib do
  alias Medappointsys.Main, as: Main
  alias Medappointsys.Patientlib
  alias Medappointsys.Queries.{Appointments, Patients, Doctors}
  alias Medappointsys.Schemas.{Patient, Doctor, Timerange, Admin, Appointment, Date}
  alias Medappointsys.Repo

  def adminMenu(adminStruct) do
    IO.write("""
    ╭─────────────────────────────╮
    | Welcome, Admin #{adminStruct.lastname}
    |─────────────────────────────|
    | (1) View Appointments       |
    | (2) View Patients           |
    | (3) View Doctors            |
    | (4) Add Doctor              |
    | (5) Remove Doctor           |
    | (6) [Logout]                |
    | (7) [Exit]                  |
    ╰─────────────────────────────╯
    """)

    input = Main.inputCheck("Input", :integer)

    case input do

    1 ->
      patientAdminOptionList(adminStruct)
      adminMenu(adminStruct)

    2 ->
      viewPatientList()
      adminMenu(adminStruct)

    3 ->
      viewDoctorList()
      adminMenu(adminStruct)

    4 ->
      Main.register_doctor()
      adminMenu(adminStruct)

    5 -> :ok
      # removeDoctor(adminStruct)
      # adminMenu(adminStruct)

    6 -> :ok

    7 -> System.halt(0)

     _  -> adminMenu(adminStruct)
    end
  end

  def patientAdminOptionList(adminStruct) do

    IO.write("""
    ╭───────────────────────────────╮
    | Which Appointment?            |
    |===============================|
    | (1) All Appointments          |
    | (2) Active Appointments       |
    | (3) Pending Appointments      |
    | (4) Completed Appointments    |
    | (5) Rescheduled Appointments  |
    | (6) Cancelled Appointments    |
    | (7) [Back]                    |
    | (8) [Exit]                    |
    ╰───────────────────────────────╯
    """)
    input = Main.inputCheck("Input", :integer)

    case input do
    1 ->
      allAppointList(adminStruct)
      patientAdminOptionList(adminStruct)
    2 ->
      activeAppointList(adminStruct)
      patientAdminOptionList(adminStruct)
    3 ->
      pendingAppointList(adminStruct)
      patientAdminOptionList(adminStruct)
    4 ->
      completedAppointList(adminStruct)
      patientAdminOptionList(adminStruct)
    5 ->
      rescheduledAppointList(adminStruct)
      patientAdminOptionList(adminStruct)
    6 ->
      cancelledAppointList(adminStruct)
      patientAdminOptionList(adminStruct)
    7 -> :ok

    8 -> System.halt(0)

     _  -> patientAdminOptionList(adminStruct)
    end
  end

  def displayAppointList(_adminStruct, appointInfo, type) do
    IO.write("""
    ╭─────────────────────────────────────────────────────────────────────────────────────────────────╮
    | #{type} Appointments List
    |─────────────────────────────────────────────────────────────────────────────────────────────────|
    """)
    Enum.each(appointInfo, fn %Appointment{
      status: status,
      reason: reason,
      doctor: %Doctor{
        firstname: doctor_firstname,
        lastname: doctor_lastname,
        specialization: specialization
      },
      patient: %Patient {
        firstname: patient_firstname,
        lastname: patient_lastname
      },
      date: %Date{
        date: appointment_date
      },
      timerange: %Timerange{
        start_time: start_time,
        end_time: end_time
      }
    } ->
    IO.write("""
    | Doctor: #{doctor_firstname} #{doctor_lastname}, Specialty: #{specialization}, Patient: #{patient_firstname} #{patient_lastname}
    | Date: #{appointment_date}, Time: #{start_time}-#{end_time}, Reason: #{reason}, Status: #{status}
    |─────────────────────────────────────────────────────────────────────────────────────────────────|
    """)
  end)
    IO.write("""
    ╰─────────────────────────────────────────────────────────────────────────────────────────────────╯
    """)
  end

  def allAppointList(adminStruct) do
    confirmed = Appointments.list_appointments("Confirmed")
    pending = Appointments.list_appointments("Pending")
    completed = Appointments.list_appointments("Completed")
    resched = Appointments.list_appointments("Rescheduled")
    cancelled = Appointments.list_appointments("Cancelled")

    appointInfo = confirmed ++ pending ++ completed ++ resched ++ cancelled

    displayAppointList(adminStruct, appointInfo, "All")
  end

  def activeAppointList(adminStruct) do
    appointInfo = Appointments.list_appointments("Confirmed")
    displayAppointList(adminStruct, appointInfo, "Active")
  end

  def pendingAppointList(adminStruct) do
    appointInfo = Appointments.list_appointments("Pending")
    displayAppointList(adminStruct, appointInfo, "Pending")
  end

  def completedAppointList(adminStruct) do
    appointInfo = Appointments.list_appointments("Completed")
    displayAppointList(adminStruct, appointInfo, "Completed")
  end

  def rescheduledAppointList(adminStruct) do
    appointInfo = Appointments.list_appointments("Rescheduled")
    displayAppointList(adminStruct, appointInfo, "Rescheduled")
  end

  def cancelledAppointList(adminStruct) do
    appointInfo = Appointments.list_appointments("Cancelled")
    displayAppointList(adminStruct, appointInfo, "Cancelled")
  end

  #-----------------------------------------------PATIENT-------------------------------------------------#

  def viewPatientList() do
    patientList = Patients.list_patients()

    len = length(patientList)
    back = len + 1
    halt = len + 2

    IO.write("""
    ╭───────────────────────────────────────────────────────╮
    | Full Patient List
    |───────────────────────────────────────────────────────|
    """)
    Enum.with_index(patientList)
    |> Enum.each(fn {element, index} ->
    IO.write("""
    | (#{index + 1}) #{element.firstname} #{element.lastname}
    """)
    end)

    IO.write("""
    | (#{back}) Back
    | (#{halt}) Exit
    ╰───────────────────────────────────────────────────────╯
    """)

        input = Main.inputCheck("Input", :integer)

        case input do
          ^back -> :ok
          ^halt -> System.halt(0)
          _ ->
            cond do
             input > len -> viewPatientList()
             input <= len -> patient = Enum.fetch(patientList, input - 1)

             patientAdminOption(elem(patient, 1))
             viewPatientList()
            end

        end
  end

  def patientAdminOption(patientStruct) do
    IO.write("""
    ╭───────────────────────────────────────────────────────╮
    | Patient Details
    |───────────────────────────────────────────────────────|
    | Firstname: #{patientStruct.firstname}
    | Lastname:  #{patientStruct.lastname}
    | Gender: #{patientStruct.gender}
    | Age: #{patientStruct.age}
    | Address: #{patientStruct.address}
    | ContactNum: #{patientStruct.contact_num}
    | Email: #{patientStruct.email}
    | Password: #{patientStruct.password}
    |=======================================================|
    | (1) Edit FirstName
    | (2) Edit LastName
    | (3) Edit Gender
    | (4) Edit Age
    | (5) Edit Address
    | (6) Edit ContactNum
    | (7) Edit Email
    | (8) Edit Password
    | (9) Back
    | (10) Exit
    |───────────────────────────────────────────────────────|
    """)

    input = Main.inputCheck("Input", :integer)

    case input do
    1 ->
      Main.inputCheck("Input New FirstName", :alpha) |>
      editPatient(patientStruct, :firstname) |>
      patientAdminOption()
    2 ->
      Main.inputCheck("Input New LastName", :alpha) |>
      editPatient(patientStruct, :lastname) |>
      patientAdminOption()
    3 ->
      Main.inputCheck("Input New Gender", :alpha) |>
      editPatient(patientStruct, :gender) |>
      patientAdminOption()
    4 ->
      Main.inputCheck("Input New Age", :integer) |>
      editPatient(patientStruct, :age) |>
      patientAdminOption()
    5 ->
      Main.inputCheck("Input New Address", :alphanum) |>
      editPatient(patientStruct, :address) |>
      patientAdminOption()
    6 ->
      Main.inputCheck("Input New ContactNum", :integer) |>
      editPatient(patientStruct, :contact_num) |>
      patientAdminOption()
    7 ->
      Main.inputCheck("Input New Email", :email) |>
      editPatient(patientStruct, :email) |>
      patientAdminOption()
    8 ->
      Main.inputCheck("Input New Password", :string) |>
      editPatient(patientStruct, :password) |>
      patientAdminOption()
    9 -> :ok

    10 -> System.halt(0)

     _  -> patientAdminOption(patientStruct)
    end

  end


  def editPatient(newVal, patientStruct, field) do
    case Patients.update_patient(patientStruct, field, newVal) do
      {:error, _} -> patientStruct
      {:ok, newPatientStruct} -> newPatientStruct
    end
  end

  #-----------------------------------------------DOCTOR-------------------------------------------------#

  def viewDoctorList() do
    doctorList = Doctors.list_doctors()

    len = length(doctorList)
    back = len + 1
    halt = len + 2

    IO.write("""
    ╭───────────────────────────────────────────────────────╮
    | Full Doctor List
    |───────────────────────────────────────────────────────|
    """)
    Enum.with_index(doctorList)
    |> Enum.each(fn {element, index} ->
    IO.write("""
    | (#{index + 1}) #{element.firstname} #{element.lastname}, #{element.specialization}
    """)
    end)

    IO.write("""
    | (#{back}) Back
    | (#{halt}) Exit
    ╰───────────────────────────────────────────────────────╯
    """)

        input = Main.inputCheck("Input", :integer)

        case input do
          ^back -> :ok
          ^halt -> System.halt(0)
          _ ->
            cond do
             input > len -> viewDoctorList()
             input <= len -> patient = Enum.fetch(doctorList, input - 1)

             doctorAdminOption(elem(patient, 1))
             viewDoctorList()
            end

        end
  end

  def doctorAdminOption(doctorStruct) do
    IO.write("""
    ╭───────────────────────────────────────────────────────╮
    | Doctor Details
    |───────────────────────────────────────────────────────|
    | Firstname: #{doctorStruct.firstname}
    | Lastname:  #{doctorStruct.lastname}
    | Gender: #{doctorStruct.gender}
    | Age: #{doctorStruct.age}
    | Address: #{doctorStruct.address}
    | ContactNum: #{doctorStruct.contact_num}
    | Specialization: #{doctorStruct.specialization}
    | Email: #{doctorStruct.email}
    | Password: #{doctorStruct.password}
    |=======================================================|
    | (1) Edit FirstName
    | (2) Edit LastName
    | (3) Edit Gender
    | (4) Edit Age
    | (5) Edit Address
    | (6) Edit ContactNum
    | (7) Edit Specialization
    | (8) Edit Email
    | (9) Edit Password
    | (10) Back
    | (11) Exit
    |───────────────────────────────────────────────────────|
    """)

    input = Main.inputCheck("Input", :integer)

    case input do
    1 ->
      Main.inputCheck("Input New FirstName", :alpha) |>
      editDoctor(doctorStruct, :firstname) |>
      doctorAdminOption()
    2 ->
      Main.inputCheck("Input New LastName", :alpha) |>
      editDoctor(doctorStruct, :lastname) |>
      doctorAdminOption()
    3 ->
      Main.inputCheck("Input New Gender", :alpha) |>
      editDoctor(doctorStruct, :gender) |>
      doctorAdminOption()
    4 ->
      Main.inputCheck("Input New Age", :integer) |>
      editDoctor(doctorStruct, :age) |>
      doctorAdminOption()
    5 ->
      Main.inputCheck("Input New Address", :alphanum) |>
      editDoctor(doctorStruct, :address) |>
      doctorAdminOption()
    6 ->
      Main.inputCheck("Input New ContactNum", :integer) |>
      editDoctor(doctorStruct, :contact_num) |>
      doctorAdminOption()

    7 ->
      Main.inputCheck("Input New Specialization", :integer) |>
      editDoctor(doctorStruct, :contact_num) |>
      doctorAdminOption()

    8 ->
      Main.inputCheck("Input New Email", :email) |>
      editDoctor(doctorStruct, :email) |>
      doctorAdminOption()
    9 ->
      Main.inputCheck("Input New Password", :string) |>
      editDoctor(doctorStruct, :password) |>
      doctorAdminOption()

    10 -> :ok

    11 -> System.halt(0)

     _  -> doctorAdminOption(doctorStruct)
    end

  end

  def editDoctor(newVal, doctorStruct, field) do
    case Doctors.update_doctor(doctorStruct, field, newVal) do
      {:error, _} -> doctorStruct
      {:ok, newDoctorStruct} -> newDoctorStruct
    end
  end

end
