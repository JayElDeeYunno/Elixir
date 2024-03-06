defmodule Medappointsys.Adminlib do
  alias Medappointsys.Main, as: Main
  alias Medappointsys.Patientlib
  alias Medappointsys.Queries.{Appointments, Patients, Doctors}
  alias Medappointsys.Schemas.{Patient, Doctor, Timerange, Admin, Appointment, Date}
  alias Medappointsys.Repo

  def adminPrompt(userType) do
    IO.write("""
    ╭─────────────────╮
    | Admin Login     |
    |─────────────────|
    | (1) Login       |
    | (2) [Back]      |
    | (3) [Exit]      |
    ╰─────────────────╯
    """)
    input = IO.gets("") |> String.trim()

    case input do

    "1" ->
        case Main.login(userType) do
          {:ok, adminStruct} ->
            adminOptions(adminStruct)
            adminPrompt(userType)

          {:error, msg} ->
            IO.puts(msg)
            adminPrompt(userType)
        end

    "2" -> :ok

    "3" -> System.halt(0)

     _  -> adminPrompt(userType)
    end
  end

  def adminOptions(adminStruct) do
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

    input = IO.gets("") |> String.trim()

    case input do

    "1" ->
      patientAdminOptionList(adminStruct)
      adminOptions(adminStruct)

    "2" -> :ok
      viewPatientList()
      adminOptions(adminStruct)

    "3" -> :ok
      # viewDoctors(adminStruct)
      # adminOptions(adminStruct)

    "4" -> :ok
      # addDoctor(adminStruct)
      # adminOptions(adminStruct)

    "5" -> :ok
      # removeDoctor(adminStruct)
      # adminOptions(adminStruct)

    "6" -> :ok

    "7" -> System.halt(0)

     _  -> adminOptions(adminStruct)
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
    input = IO.gets("") |> String.trim()

    case input do
    "1" ->
      allAppointList(adminStruct)
      patientAdminOptionList(adminStruct)
    "2" ->
      activeAppointList(adminStruct)
      patientAdminOptionList(adminStruct)
    "3" ->
      pendingAppointList(adminStruct)
      patientAdminOptionList(adminStruct)
    "4" ->
      completedAppointList(adminStruct)
      patientAdminOptionList(adminStruct)
    "5" ->
      rescheduledAppointList(adminStruct)
      patientAdminOptionList(adminStruct)
    "6" ->
      cancelledAppointList(adminStruct)
      patientAdminOptionList(adminStruct)
    "7" -> :ok

    "8" -> System.halt(0)

     _  -> patientAdminOptionList(adminStruct)
    end
  end

  def displayAppointList(_adminStruct, appointInfo, type) do
    IO.write("""
    ╭──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────╮
    | #{type} Appointments List
    |──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────|
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
    | Doctor: #{doctor_firstname} #{doctor_lastname}, Specialty: #{specialization}, Patient: #{patient_firstname} #{patient_lastname}, Date: #{appointment_date}, Time: #{start_time}-#{end_time}, Reason: #{reason}, Status: #{status}
    |──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────|
    """)
  end)
    IO.write("""
    ╰──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────╯
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

        # no checker
        input = IO.gets("") |> String.trim() |> String.to_integer()

        case input do
          ^back -> :ok
          ^halt -> System.halt(0)
          _ ->
            cond do
             input > len -> viewPatientList()
             input <= len -> patient = Enum.fetch(patientList, input - 1)

             patientAdminOption(elem(patient, 1))
            end

        end
  end

  # def hide(pass) do
  #   String.replace(pass, ~r/./, "*")
  # end

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

    input = IO.gets("") |> String.trim()

    case input do
    "1" ->
      editPatient(patientStruct, :firstname, 0) |>
      patientAdminOption()
    "2" ->
      editPatient(patientStruct, :lastname, 0) |>
      patientAdminOption()
    "3" ->
      editPatient(patientStruct, :gender, 0) |>
      patientAdminOption()
    "4" ->
      editPatient(patientStruct, :age, 1) |>
      patientAdminOption()
    "5" ->
      editPatient(patientStruct, :address, 0) |>
      patientAdminOption()
    "6" ->
      editPatient(patientStruct, :contact_num, 0) |>
      patientAdminOption()
    "7" ->
      editPatient(patientStruct, :email, 0) |>
      patientAdminOption()
    "8" ->
      editPatient(patientStruct, :password, 0) |>
      patientAdminOption()
    "9" -> :ok

    "10" -> System.halt(0)

     _  -> patientAdminOption(patientStruct)
    end

  end


  def editPatient(patientStruct, field, type) do
      # no checker
      newVal = IO.gets("Enter new value: ") |> String.trim()


      case Patients.update_patient(patientStruct, field, newVal) do
        {:error, _} -> patientStruct
        {:ok, newPatientStruct} -> newPatientStruct
      end
  end

end
