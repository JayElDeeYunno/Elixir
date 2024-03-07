defmodule Medappointsys.Patientlib do
  alias Medappointsys.Main, as: Main
  alias Medappointsys.Queries.Appointments, as: Appointments
  alias Medappointsys.Queries.Doctors, as: Doctors
  alias Medappointsys.Queries.Dates, as: Dates
  alias Medappointsys.Schemas.{Patient, Doctor, Timerange, Admin, Appointment, Date}

  def patientPrompt(userType) do
    IO.write("""
    ╭─────────────────╮
    | Patient Login   |
    |─────────────────|
    | (1) Login       |
    | (2) Register    |
    | (3) [Back]      |
    | (4) [Exit]      |
    ╰─────────────────╯
    """)
    doctor_input = IO.gets("") |> String.trim()

    case doctor_input do
    "1" ->
      case Main.login(userType) do
        {:ok, patientStruct} ->
          patientOptions(patientStruct)
          patientPrompt(userType)

        {:error, msg} ->
          IO.puts(msg)
          patientPrompt(userType)
      end
    "2" ->
      Main.register(userType)
      patientPrompt(userType)

    "3" -> :ok

    "4" -> System.halt(0)

    _  -> patientPrompt(userType)
    end
  end

  def patientOptions(patientStruct) do

    IO.write("""
    ╭─────────────────────────────╮
    | Welcome, #{patientStruct.firstname} #{patientStruct.lastname}
    |─────────────────────────────|
    | (1) View Notif Box          |
    | (2) Request Appointment     |
    | (3) Resched Appointment     |
    | (4) Cancel Appointment      |
    | (5) View Appointments       |
    | (6) [Logout]                |
    | (7) [Exit]                  |
    ╰─────────────────────────────╯
    """)
    doctor_input = IO.gets("") |> String.trim()

    case doctor_input do

    "1" ->
      viewInbox(patientStruct)
      patientOptions(patientStruct)

    "2" ->
      requestAppoint(patientStruct)
      patientOptions(patientStruct)

    "3" ->
      reschedAppoint(patientStruct)
      patientOptions(patientStruct)

    "4" ->
      cancelAppoint(patientStruct)
      patientOptions(patientStruct)

    "5" ->
      viewAppoint(patientStruct)
      patientOptions(patientStruct)

    "6" -> :ok

    "7" -> System.halt(0)

    _  -> patientOptions(patientStruct)
    end
  end

  def viewInbox(patientStruct) do
      IO.write("""
      ╭─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────╮
      | #{patientStruct.firstname} #{patientStruct.lastname}'s Notifications
      |─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────|
      """)
      Appointments.get_patient_appointments(patientStruct.id)
      |> Enum.each(fn %Appointment{
        status: status,
        reason: reason,
        doctor: %Doctor{
          lastname: doctor_lastname,
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
      | Your Appointment with Dr. #{doctor_lastname} scheduled on #{appointment_date} due to #{reason} at #{start_time}-#{end_time} is #{status}.
      |─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────|
      """)
      end)
      IO.write("""
      ╰─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────╯
      """)
    end

    def requestAppoint(patientStruct) do
      doctorList = Doctors.list_doctors()

      len = length(doctorList)
      back = len + 1

      IO.write("""
      ╭───────────────────────────────────────────────────────╮
      | Select a Doctor for Appointment
      |───────────────────────────────────────────────────────|
      """)
      Enum.with_index(doctorList)
      |> Enum.each(fn {element, index} ->
        IO.write("""
        | (#{index + 1}) Dr. #{element.firstname} #{element.lastname}, #{element.specialization}
        """)
      end)

      IO.write("""
      | (#{back}) Back
      ╰───────────────────────────────────────────────────────╯
      """)

      doctor_input = Main.inputCheck("Input", :integer)

      case doctor_input do
        ^back -> :ok
        _ ->
          case Enum.fetch(doctorList, doctor_input - 1) do
            {:ok, selected_doctor} ->
              IO.puts("Selected Doctor: Dr. #{selected_doctor.firstname} #{selected_doctor.lastname}")
              date_input = Main.inputCheck("Enter Date (YYYY-MM-DD)", :date)

              selected_date =
                date_input
                |> Dates.date_exists?
                |> case do
                  false -> Dates.create_date(%{date: date_input})
                  true -> Dates.get_date_by_date(date_input)
                end

              doctor_timeranges = Doctors.get_timeranges(selected_doctor)

              IO.puts("Available Time Ranges:")
              Enum.with_index(doctor_timeranges, 1) |> Enum.each(fn {timerange, index} ->
                IO.puts("(#{index}) #{timerange.start_time} - #{timerange.end_time}")
              end)

              timerange_input = Main.inputCheck("Select Time Range (Input the corresponding number)", :integer)

              case Enum.fetch(doctor_timeranges, timerange_input - 1) do
                {:ok, selected_timerange} ->
                  IO.puts("Selected Time Range: #{selected_timerange.start_time} - #{selected_timerange.end_time}")

                  reason = Main.inputCheck("Enter Reason", :string)

                  # Create appointment logic here
                  Appointments.create_appointment%{
                    patient_id: patientStruct.id,
                    doctor_id: selected_doctor.id,
                    date_id: selected_date.id,
                    timerange_id: selected_timerange.id,
                    reason: reason,
                    status: "Pending"
                  }

                _ -> IO.puts("Invalid time range selection.")
              end
            _ -> IO.puts("Invalid selection.")
          end
      end
    end


  def reschedAppoint(patientStruct) do

  end

  def cancelAppoint(patientStruct) do

  end

  def viewAppoint(patientStruct) do

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
    doctor_input = IO.gets("") |> String.trim()

    case doctor_input do
    "1" ->
      allAppoint(patientStruct)
      viewAppoint(patientStruct)
    "2" ->
      activeAppoint(patientStruct)
      viewAppoint(patientStruct)
    "3" ->
      pendingAppoint(patientStruct)
      viewAppoint(patientStruct)
    "4" ->
      completedAppoint(patientStruct)
      viewAppoint(patientStruct)
    "5" ->
      rescheduledAppoint(patientStruct)
      viewAppoint(patientStruct)
    "6" ->
      cancelledAppoint(patientStruct)
      viewAppoint(patientStruct)
    "7" -> :ok

    "8" -> System.halt(0)

    _  -> patientOptions(patientStruct)
    end
  end

  def displayAppoint(patientStruct, appointInfo, type) do
    IO.write("""
    ╭─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────╮
    | #{patientStruct.firstname} #{patientStruct.lastname}'s #{type} Appointments
    |─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────|
    """)
    Enum.each(appointInfo, fn %Appointment{
      status: status,
      reason: reason,
      doctor: %Doctor{
        firstname: doctor_firstname,
        lastname: doctor_lastname,
        specialization: specialization
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
    | Doctor: #{doctor_firstname} #{doctor_lastname}, Specialty: #{specialization}, Date: #{appointment_date}, Time: #{start_time}-#{end_time}, Reason: #{reason}, Status: #{status}
    |─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────|
    """)
  end)
    IO.write("""
    ╰─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────╯
    """)
  end

  def allAppoint(patientStruct) do
    confirmed = Appointments.filter_patient_appointments(patientStruct.id, "Confirmed")
    pending = Appointments.filter_patient_appointments(patientStruct.id, "Pending")
    completed = Appointments.filter_patient_appointments(patientStruct.id, "Completed")
    resched = Appointments.filter_patient_appointments(patientStruct.id, "Rescheduled")
    cancelled = Appointments.filter_patient_appointments(patientStruct.id, "Cancelled")

    appointInfo = confirmed ++ pending ++ completed ++ resched ++ cancelled

    displayAppoint(patientStruct, appointInfo, "All")
  end

  def activeAppoint(patientStruct) do
    appointInfo = Appointments.filter_patient_appointments(patientStruct.id, "Confirmed")
    displayAppoint(patientStruct, appointInfo, "Active")
  end

  def pendingAppoint(patientStruct) do
    appointInfo = Appointments.filter_patient_appointments(patientStruct.id, "Pending")
    displayAppoint(patientStruct, appointInfo, "Pending")
  end

  def completedAppoint(patientStruct) do
    appointInfo = Appointments.filter_patient_appointments(patientStruct.id, "Completed")
    displayAppoint(patientStruct, appointInfo, "Completed")
  end

  def rescheduledAppoint(patientStruct) do
    appointInfo = Appointments.filter_patient_appointments(patientStruct.id, "Rescheduled")
    displayAppoint(patientStruct, appointInfo, "Rescheduled")
  end

  def cancelledAppoint(patientStruct) do
    appointInfo = Appointments.filter_patient_appointments(patientStruct.id, "Cancelled")
    displayAppoint(patientStruct, appointInfo, "Cancelled")
  end

end
