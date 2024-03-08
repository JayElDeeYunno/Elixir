defmodule Medappointsys.Patientlib do
  alias Medappointsys.Main
  alias Medappointsys.Queries.Appointments
  alias Medappointsys.Queries.Doctors

  def patientMenu(patientStruct) do
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

    input = Main.inputCheck("Input", :integer)

    case input do
      1 ->
        viewInbox(patientStruct)
        patientMenu(patientStruct)

      2 ->
        requestAppoint(patientStruct)
        patientMenu(patientStruct)

      3 ->
        reschedAppoint(patientStruct)
        patientMenu(patientStruct)

      4 ->
        cancelAppoint(patientStruct)
        patientMenu(patientStruct)

      5 ->
        viewAppoint(patientStruct)
        patientMenu(patientStruct)

      6 -> :ok

      7 -> System.halt(0)

      _ ->
        patientMenu(patientStruct)
    end
  end

  def viewInbox(patientStruct) do
    IO.write("""
    ╭─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────╮
    | #{patientStruct.firstname} #{patientStruct.lastname}'s Notifications
    |─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────|
    """)
    Appointments.get_patient_appointments(patientStruct.id)
    |> Enum.each(fn appointment ->
      IO.write("""
      | Your Appointment with Dr. #{appointment.doctor.lastname} scheduled on #{appointment.date.date} due to #{appointment.reason} at #{appointment.timerange.start_time}-#{appointment.timerange.end_time} is #{appointment.status}.
      |─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────|
      """)
    end)
    IO.write("""
    ╰─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────╯
    """)
  end

  def timeslot_scheduling(patientStruct, doctor_list, chosen_input) do
    case Enum.fetch(doctor_list, chosen_input - 1) do
      {:ok, selected_doctor} ->

        unavailabilities = Doctors.list_unavailabilities(selected_doctor.id)
        selected_date = Main.isUnavailableDate(selected_doctor, unavailabilities)

        doctor_timeranges = Doctors.get_timeranges(selected_doctor)
        existing_appointments = Appointments.filter_date_doctor_appointments(selected_doctor.id, selected_date.id, ["Pending", "Reschedule", "Confirmed"])

        available_timeranges =
          doctor_timeranges
          |> Enum.reject(fn timerange ->
            Enum.any?(existing_appointments, fn appointment ->
              appointment.timerange_id == timerange.id and appointment.date_id == selected_date.id
            end)
          end)

        len = length(available_timeranges)
        back = len + 1
        halt = len + 2

        IO.write("""
        ╭─────────────────────────────────────────────────────────────────────────────────────────────────╮
        | Available Time Slots for Dr. #{selected_doctor.lastname}
        |─────────────────────────────────────────────────────────────────────────────────────────────────|
        """)

        Enum.with_index(available_timeranges)
        |> Enum.each(fn {timerange, index} ->
          IO.write("""
          | (#{index + 1}) #{timerange.start_time} - #{timerange.end_time}
          """)
        end)

        IO.write("""
        |─────────────────────────────────────────────────────────────────────────────────────────────────|
        | (#{back}) Back
        | (#{halt}) Halt
        ╰─────────────────────────────────────────────────────────────────────────────────────────────────╯
        """)

        timerange_input = Main.inputCheck("Select Time Range (Input the corresponding number)", :integer)

        case timerange_input do
          ^back -> :ok
          ^halt -> System.halt(0)
          _ ->
            case Enum.fetch(available_timeranges, timerange_input - 1) do
              {:ok, selected_timerange} ->
                IO.puts("""
                ╭──────────────────────────────────────────────────────────────────────────────────────────────────╮
                | Selected Time Range: #{selected_timerange.start_time} - #{selected_timerange.end_time}
                ╰──────────────────────────────────────────────────────────────────────────────────────────────────╯
                """)
                reason = Main.inputCheck("Enter Reason", :string)
                Appointments.create_appointment(%{
                  patient_id: patientStruct.id,
                  doctor_id: selected_doctor.id,
                  date_id: selected_date.id,
                  timerange_id: selected_timerange.id,
                  reason: reason,
                  status: "Pending"
                })

                IO.write("""
                ╭─────────────────────────────────────────────────────────────────────────────────────────────────╮
                | Your appointment request has been submitted. Please await confirmation from the doctor.
                ╰─────────────────────────────────────────────────────────────────────────────────────────────────╯
                """)
                requestAppoint(patientStruct)

              _ -> timeslot_scheduling(patientStruct, doctor_list, chosen_input)
            end
        end

        _ -> requestAppoint(patientStruct)
      end
  end

  def requestAppoint(patientStruct) do

    doctor_list = Doctors.list_doctors()
    len = length(doctor_list)
    back = len + 1
    halt = len + 2

    IO.write("""
    ╭───────────────────────────────────────────────────────╮
    | Select a Doctor for Appointment
    |───────────────────────────────────────────────────────|
    """)
    Enum.with_index(doctor_list)
    |> Enum.each(fn {doctor, index} ->
    IO.write("""
    | (#{index + 1}) Dr. #{doctor.firstname} #{doctor.lastname}, #{doctor.specialization}
    """)
    end)
    IO.write("""
    | (#{back}) Back
    | (#{halt}) Halt
    ╰───────────────────────────────────────────────────────╯
    """)

    doctor_input = Main.inputCheck("Input", :integer)

    case doctor_input do
      ^back -> :ok
      ^halt -> System.halt(0)

      _ -> timeslot_scheduling(patientStruct, doctor_list, doctor_input)

    end
  end

  def pending_resched_request(patientStruct, pending_appointments_list, chosen_index) do
    case Enum.fetch(pending_appointments_list, chosen_index - 1) do
      {:ok, selected_appointment} ->

        Main.displayAppointments([selected_appointment], "Selected Appointment", "Patient", false)

        unavailabilities = Doctors.list_unavailabilities(selected_appointment.doctor.id)
        selected_date = Main.isUnavailableDate(selected_appointment.doctor, unavailabilities)

        doctor_timeranges = Doctors.get_timeranges(selected_appointment.doctor)
        existing_appointments = Appointments.filter_date_doctor_appointments(selected_appointment.doctor.id, selected_date.id, ["Pending", "Reschedule", "Confirmed"])

        available_timeranges =
          doctor_timeranges
          |> Enum.reject(fn timerange ->
            Enum.any?(existing_appointments, fn appointment ->
              appointment.timerange_id == timerange.id and appointment.date_id == selected_date.id
            end)
          end)

        len = length(available_timeranges)
        back = len + 1
        halt = len + 2

        IO.write("""
        ╭─────────────────────────────────────────────────────────────────────────────────────────────────╮
        | Available Time Slots                                                                            |
        |─────────────────────────────────────────────────────────────────────────────────────────────────|
        """)
        Enum.with_index(available_timeranges)
        |> Enum.each(fn {timerange, index} ->
        IO.write("""
        | (#{index + 1}) #{timerange.start_time} - #{timerange.end_time}
        """)
        end)
        IO.write("""
        |─────────────────────────────────────────────────────────────────────────────────────────────────|
        | (#{back}) Back                                                                                  |
        | (#{halt}) Halt                                                                                  |
        ╰─────────────────────────────────────────────────────────────────────────────────────────────────╯
        """)

        timerange_input = Main.inputCheck("Select Time Range (Input the corresponding number)", :integer)

        case Enum.fetch(available_timeranges, timerange_input - 1) do
          {:ok, selected_timerange} ->
            IO.write("""
            ╭──────────────────────────────────────────────────────────────────────────────────────────────────╮
            | Selected Time Range: #{selected_timerange.start_time} - #{selected_timerange.end_time}
            ╰──────────────────────────────────────────────────────────────────────────────────────────────────╯
            """)

            update_attrs = %{
              date_id: selected_date.id,
              timerange_id: selected_timerange.id,
              status: "Reschedule"
            }

            Appointments.update_appointment(selected_appointment, update_attrs)

            IO.write("""
            ╭─────────────────────────────────────────────────────────────────────────────────────────────────╮
            | Your reschedule request has been submitted. Please wait for Doctor Confirmation                 |
            ╰─────────────────────────────────────────────────────────────────────────────────────────────────╯
            """)
            _ ->
              IO.puts("Invalid time slot")
              pending_resched_request(patientStruct, pending_appointments_list, chosen_index)
        end
        _ -> pending_resched_menu(patientStruct)
      end
  end

  def pending_resched_menu(patientStruct) do
    pending_appointments_list = Appointments.filter_patient_appointments(patientStruct.id, ["Pending"])

    len = length(pending_appointments_list)
    back = len + 1
    halt = len + 2

    Main.displayAppointments(pending_appointments_list, "Your Pending Appointments List", "Patient")

    appointment_input = Main.inputCheck("Input", :integer)

    case appointment_input do
      ^back -> :ok
      ^halt -> System.halt(0)

      _ -> pending_resched_request(patientStruct, pending_appointments_list, appointment_input)

    end
  end

  def active_resched_menu(patientStruct) do
    confirmed_appointments_list =
      Appointments.filter_patient_appointments(patientStruct.id, ["Confirmed"])

    len = length(confirmed_appointments_list)
    back = len + 1
    halt = len + 2

    Main.displayAppointments(confirmed_appointments_list, "Your Active Appointments List", "Patient")
    appointment_input = Main.inputCheck("Input", :integer)

    case appointment_input do
      ^back -> :ok
      ^halt -> System.halt(0)

      _ -> active_resched_request(patientStruct, confirmed_appointments_list, appointment_input)

    end
  end

  def active_resched_request(patientStruct, confirmed_appointments_list, chosen_index) do
    case Enum.fetch(confirmed_appointments_list, chosen_index - 1) do
      {:ok, selected_appointment} ->

        Main.displayAppointments([selected_appointment], "Selected Appointment", "Patient", false)

        unavailabilities = Doctors.list_unavailabilities(selected_appointment.doctor.id)
        selected_date = Main.isUnavailableDate(selected_appointment.doctor, unavailabilities)

        doctor_timeranges = Doctors.get_timeranges(selected_appointment.doctor)
        existing_appointments = Appointments.filter_date_doctor_appointments(selected_appointment.doctor.id, selected_date.id, ["Pending", "Reschedule", "Confirmed"])

        available_timeranges =
          doctor_timeranges
          |> Enum.reject(fn timerange ->
            Enum.any?(existing_appointments, fn appointment ->
              appointment.timerange_id == timerange.id and appointment.date_id == selected_date.id
            end)
          end)

        len = length(available_timeranges)
        back = len + 1
        halt = len + 2

        IO.write("""
        ╭─────────────────────────────────────────────────────────────────────────────────────────────────╮
        | Available Time Slots                                                                            |
        |─────────────────────────────────────────────────────────────────────────────────────────────────|
        """)
        Enum.with_index(available_timeranges)
        |> Enum.each(fn {timerange, index} ->
          IO.write("""
          | (#{index}) #{timerange.start_time} - #{timerange.end_time}
          """)
        end)
        IO.write("""
        |─────────────────────────────────────────────────────────────────────────────────────────────────|
        | (#{back}) Back                                                                                  |
        | (#{halt}) Halt                                                                                               |
        ╰─────────────────────────────────────────────────────────────────────────────────────────────────╯
        """)

        timerange_input =
          Main.inputCheck("Select Time Range (Input the corresponding number)", :integer)

        case Enum.fetch(available_timeranges, timerange_input - 1) do
          {:ok, selected_timerange} ->
            IO.puts("""
            ╭──────────────────────────────────────────────────────────────────────────────────────────────────╮
            | Selected Time Range: #{selected_timerange.start_time} - #{selected_timerange.end_time}
            ╰──────────────────────────────────────────────────────────────────────────────────────────────────╯
            """)

            update_attrs = %{
              date_id: selected_date.id,
              timerange_id: selected_timerange.id,
              status: "Reschedule"
            }

            Appointments.update_appointment(selected_appointment, update_attrs)

            IO.write("""
            ╭──────────────────────────────────────────────────────────────────────────────────────╮
            | Your reschedule request has been submitted. Please wait for Doctor Confirmation      |
            ╰──────────────────────────────────────────────────────────────────────────────────────╯
            """)
          _ -> active_resched_request(patientStruct, confirmed_appointments_list, chosen_index)
        end

        _ -> active_resched_menu(patientStruct)
    end
  end

  def reschedAppoint(patientStruct) do
    IO.write("""
    ╭─────────────────────────────╮
    | Choose Reschedule Options   |
    |─────────────────────────────|
    | (1) Pending Appointments    |
    | (2) Active Appointments     |
    | (3) Back                    |
    | (4) Exit                    |
    ╰─────────────────────────────╯
    """)

    reschedule_input = Main.inputCheck("Input", :integer)

    case reschedule_input do
      1 -> pending_resched_menu(patientStruct)

      2 -> active_resched_menu(patientStruct)

      3 -> :ok

      4 -> System.halt(0)

      _ -> reschedAppoint(patientStruct)
    end
  end

  def confirm_cancel_menu(patientStruct) do
    active_appointments_list = Appointments.filter_patient_appointments(patientStruct.id, ["Confirmed"])

      len = length(active_appointments_list)
      back = len + 1
      halt = len + 2

      Main.displayAppointments(active_appointments_list, "Your Active Appointments List", "Patient")
      appointment_input = Main.inputCheck("Input", :integer)

      case appointment_input do
        ^back -> :ok
        ^halt -> System.halt(0)

        _ -> general_cancel_request(patientStruct, active_appointments_list, appointment_input, :confirm)

      end
  end

  def pending_cancel_menu(patientStruct) do
    pending_appointments_list = Appointments.filter_patient_appointments(patientStruct.id, ["Pending"])

      len = length(pending_appointments_list)
      back = len + 1
      halt = len + 2

      Main.displayAppointments(pending_appointments_list, "Your Active Appointments List", "Patient")
      appointment_input = Main.inputCheck("Input", :integer)

      case appointment_input do
        ^back -> :ok
        ^halt -> System.halt(0)

        _ -> general_cancel_request(patientStruct, pending_appointments_list, appointment_input, :pending)

      end
  end

  def reschedule_cancel_menu(patientStruct) do
    reschedule_appointments_list = Appointments.filter_patient_appointments(patientStruct.id, ["Reschedule"])

      len = length(reschedule_appointments_list)
      back = len + 1
      halt = len + 2

      Main.displayAppointments(reschedule_appointments_list, "Your Active Appointments List", "Patient")
      appointment_input = Main.inputCheck("Input", :integer)

      case appointment_input do
        ^back -> :ok
        ^halt -> System.halt(0)

        _ -> general_cancel_request(patientStruct, reschedule_appointments_list, appointment_input, :reschedule)

      end
  end

  def general_cancel_request(patientStruct, appointments_list, chosen_index, label) do
    case Enum.fetch(appointments_list, chosen_index - 1) do
      {:ok, selected_appointment} ->

        Main.displayAppointments([selected_appointment], "Selected Appointment", "Patient", false)

        update_attrs = %{status: "Cancelled"}
        Appointments.update_appointment(selected_appointment, update_attrs)

        IO.write("""
        ╭─────────────────────────────────────────────────────────────────────────────────────────────────╮
        | The selected appointment has been cancelled.                                                    |
        ╰─────────────────────────────────────────────────────────────────────────────────────────────────╯
        """)

      _ ->
        case label do
          :confirm -> confirm_cancel_menu(patientStruct)
          :pending -> pending_cancel_menu(patientStruct)
          :reschedule -> reschedule_cancel_menu(patientStruct)
        end
    end
  end


  def cancelAppoint(patientStruct) do
    IO.write("""
    ╭───────────────────────────────╮
    | Which Appointment?            |
    |===============================|
    | (1) Active Appointments       |
    | (2) Pending Appointments      |
    | (3) Rescheduled Appointments  |
    | (4) [Back]                    |
    ╰───────────────────────────────╯
    """)

    cancel_input = Main.inputCheck("Input", :integer)

    case cancel_input do
      1 -> confirm_cancel_menu(patientStruct)

      2 -> pending_cancel_menu(patientStruct)

      3 -> reschedule_cancel_menu(patientStruct)

      4 -> :ok

      _ -> cancelAppoint(patientStruct)
    end
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

    input = Main.inputCheck("Input", :integer)

    case input do
      1 ->
        allAppoint(patientStruct)
        viewAppoint(patientStruct)

      2 ->
        activeAppoint(patientStruct)
        viewAppoint(patientStruct)

      3 ->
        pendingAppoint(patientStruct)
        viewAppoint(patientStruct)

      4 ->
        completedAppoint(patientStruct)
        viewAppoint(patientStruct)

      5 ->
        rescheduledAppoint(patientStruct)
        viewAppoint(patientStruct)

      6 ->
        cancelledAppoint(patientStruct)
        viewAppoint(patientStruct)

      7 -> :ok

      8 ->
        System.halt(0)

      _ ->
        viewAppoint(patientStruct)
    end
  end

  def allAppoint(patientStruct) do
    confirmed = Appointments.filter_patient_appointments(patientStruct.id, ["Confirmed"])
    pending = Appointments.filter_patient_appointments(patientStruct.id, ["Pending"])
    completed = Appointments.filter_patient_appointments(patientStruct.id, ["Completed"])
    resched = Appointments.filter_patient_appointments(patientStruct.id, ["Rescheduled"])
    cancelled = Appointments.filter_patient_appointments(patientStruct.id, ["Cancelled"])

    appointInfo = confirmed ++ pending ++ completed ++ resched ++ cancelled
    Main.displayAppointments(appointInfo, "All Appointments", "Patient")
  end

  def activeAppoint(patientStruct) do
    appointInfo = Appointments.filter_patient_appointments(patientStruct.id, ["Confirmed"])
    Main.displayAppointments(appointInfo, "Active Appointments", "Patient")
  end

  def pendingAppoint(patientStruct) do
    appointInfo = Appointments.filter_patient_appointments(patientStruct.id, ["Pending"])
    Main.displayAppointments(appointInfo, "Pending Appointments", "Patient")
  end

  def completedAppoint(patientStruct) do
    appointInfo = Appointments.filter_patient_appointments(patientStruct.id, ["Completed"])
    Main.displayAppointments(appointInfo, "Completed Appointments", "Patient")
  end

  def rescheduledAppoint(patientStruct) do
    appointInfo = Appointments.filter_patient_appointments(patientStruct.id, ["Reschedule"])
    Main.displayAppointments(appointInfo, "Reschedule Appointments", "Patient")
  end

  def cancelledAppoint(patientStruct) do
    appointInfo = Appointments.filter_patient_appointments(patientStruct.id, ["Cancelled"])
    Main.displayAppointments(appointInfo, "Cancelled Appointments", "Patient")
  end
end
