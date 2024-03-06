defmodule Medappointsys.Adminlib do
  alias Medappointsys.Main, as: Main
  alias Medappointsys.Patientlib
  alias Medappointsys.Queries.{Appointments, Patients, Doctors}
  alias Medappointsys.Schemas.{Patient, Doctor, Timerange, Admin, Appointment, Date}
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
      viewAppointList(adminStruct)
      adminOptions(adminStruct)

    "2" -> :ok
      # viewPatients(adminStruct)
      # adminOptions(adminStruct)

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

  def viewAppointList(adminStruct) do

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
      viewAppointList(adminStruct)
    "2" ->
      activeAppointList(adminStruct)
      viewAppointList(adminStruct)
    "3" ->
      pendingAppointList(adminStruct)
      viewAppointList(adminStruct)
    "4" ->
      completedAppointList(adminStruct)
      viewAppointList(adminStruct)
    "5" ->
      rescheduledAppointList(adminStruct)
      viewAppointList(adminStruct)
    "6" ->
      cancelledAppointList(adminStruct)
      viewAppointList(adminStruct)
    # "7" -> :ok

    # "8" -> System.halt(0)

    #  _  -> patientOptions(adminStruct)
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

end
