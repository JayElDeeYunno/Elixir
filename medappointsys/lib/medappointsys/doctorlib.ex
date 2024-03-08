defmodule Medappointsys.Doctorlib do
  alias Medappointsys.Adminlib
  alias Medappointsys.Main
  alias Medappointsys.Queries.{Appointments, Doctors, Dates}

  def confirm_or_cancel_appointment(doctorStruct, appointment_list, chosen_index) do
    case Enum.fetch(appointment_list, chosen_index - 1) do
      {:ok, selected_appointment} ->

        Main.displayAppointments([selected_appointment], "Selected Appointment", "Doctor", false)
        input = Main.dialogBox("Action", ["Confirm Appointment", "Cancel Appointment"])

        case input do
          1 ->
            update_attrs = %{status: "Confirmed"}
            Appointments.update_appointment(selected_appointment, update_attrs)

            IO.write("""
            ╭─────────────────────────────────────────────────────────────────────────────────────────────────╮
            | The selected appointment has been confirmed. The patient will be notified.                      |
            ╰─────────────────────────────────────────────────────────────────────────────────────────────────╯
            """)

          2 ->
            update_attrs = %{status: "Cancelled"}
            Appointments.update_appointment(selected_appointment, update_attrs)

            IO.write("""
            ╭─────────────────────────────────────────────────────────────────────────────────────────────────╮
            | The selected appointment has been cancelled. The patient will be notified.                      |
            ╰─────────────────────────────────────────────────────────────────────────────────────────────────╯
            """)

          :ok -> :ok
        end

        _ ->  viewAppointmentRequests(doctorStruct)
      end
  end
  def delete_or_nil_appointment(doctorStruct, appointment_list, chosen_index) do
    case Enum.fetch(appointment_list, chosen_index - 1) do
      {:ok, selected_appointment} ->

        Main.displayAppointments([selected_appointment], "Selected Appointment", "Doctor", false)
        input = Main.dialogBox("Action", ["Delete Appointment"])

        case input do
          1 ->
            Appointments.delete_appointment(selected_appointment)

            IO.write("""
            ╭─────────────────────────────────────────────────────────────────────────────────────────────────╮
            | The selected appointment has been deleted                                                       |
            ╰─────────────────────────────────────────────────────────────────────────────────────────────────╯
            """)
            appointmentsEditMenu(doctorStruct)
          :ok -> :ok
        end
        _ -> appointmentsEditMenu(doctorStruct)
    end
  end

  def select_or_delete_appointment(doctorStruct, appointment_list, chosen_index) do
    case Enum.fetch(appointment_list, chosen_index - 1) do
      {:ok, selected_appointment} ->

        Main.displayAppointments([selected_appointment], "Selected Patient", "Doctor", false)
        input = Main.dialogBox("Action", ["Check Appointments", "Delete Patient"])

        case input do
          1 ->
            patient_appointments_list =
              Appointments.get_patient_appointments(selected_appointment.patient.id)
              |> Main.ensure_list()

            Main.displayAppointments(patient_appointments_list, "All Appointments", "Doctor", false)
            viewPatients(doctorStruct)

          2 -> Adminlib.full_delete_patient(selected_appointment.patient)
            viewPatients(doctorStruct)

          :ok -> :ok
        end

        _ -> viewPatients(doctorStruct)
    end
  end

  def delete_unavailability(doctorStruct, unavailabilities_list) do

    len = length(unavailabilities_list)
    back = len + 1
    halt = len + 2

    if (len) > 0 do


      IO.write("""
      ╭─────────────────────────────────────────────────────────────────────────────────────────────────╮
      | Select Date to Delete                                                                           |
      |─────────────────────────────────────────────────────────────────────────────────────────────────|
      """)
      Enum.with_index(unavailabilities_list)
      |> Enum.each(fn {unavailable, index} ->
      IO.write("""
      | (#{index + 1}) Date: #{unavailable.date.date}
      """)
      end)
      IO.write("""
      |─────────────────────────────────────────────────────────────────────────────────────────────────|
      | (#{back}) Back
      | (#{halt}) Exit
      ╰─────────────────────────────────────────────────────────────────────────────────────────────────╯
      """)

      delete_input = Main.inputCheck("Input", :integer)

      case delete_input do
        ^back -> :ok
        ^halt -> System.halt(0)

        _ ->
          case Enum.fetch(unavailabilities_list, delete_input - 1) do
            {:ok, selected_unavailability} ->
              Doctors.delete_unavailability(selected_unavailability)

              IO.write("""
              ╭──────────────────────────────────────────────────────────────────────────────────────╮
              | Unavailable date has been removed.                                                   |
              ╰──────────────────────────────────────────────────────────────────────────────────────╯
              """)
              setUnavailability(doctorStruct)

            _ -> delete_unavailability(doctorStruct, unavailabilities_list)
          end
      end

    else
      IO.write("""
      ╭──────────────────────────────────────────────────────────────────────────────────────╮
      | There are no unavailability dates to be removed.                                     |
      ╰──────────────────────────────────────────────────────────────────────────────────────╯
      """)
      setUnavailability(doctorStruct)
    end
  end

  def complete_or_cancel_appointment(doctorStruct, appointment_list, chosen_index) do
    case Enum.fetch(appointment_list, chosen_index - 1) do
      {:ok, selected_appointment} ->

        Main.displayAppointments([selected_appointment], "Selected Appointment", "Doctor", false)
        input = Main.dialogBox("Action", ["Mark as Completed", "Cancel Appointment"])

        case input do
          1 ->
            update_attrs = %{status: "Completed"}
            Appointments.update_appointment(selected_appointment, update_attrs)

            IO.write("""
            ╭─────────────────────────────────────────────────────────────────────────────────────────────────╮
            | The selected appointment has been marked completed.                                             |
            ╰─────────────────────────────────────────────────────────────────────────────────────────────────╯
            """)

          2 ->
            update_attrs = %{status: "Cancelled"}
            Appointments.update_appointment(selected_appointment, update_attrs)

            IO.write("""
            ╭─────────────────────────────────────────────────────────────────────────────────────────────────╮
            | The selected appointment has been cancelled. The patient will be notified.                      |
            ╰─────────────────────────────────────────────────────────────────────────────────────────────────╯
            """)

          :ok -> :ok
        end

        _ -> viewActiveAppointments(doctorStruct)
      end
  end

  def doctorMenu(doctorStruct) do
    IO.write("""
    ╭─────────────────────────────────╮
    | Welcome, Dr. #{doctorStruct.lastname}
    |─────────────────────────────────|
    | (1) Appointment Requests        |
    | (2) Upcoming Appointments       |
    |                                 |
    | (3) View Appointments           |
    | (4) View Patients               |
    |                                 |
    | (5) Set Unavailability          |
    | (6) Set Time Slots              |
    |                                 |
    | (7) [Logout]                    |
    | (8) [Exit]                      |
    ╰─────────────────────────────────╯
    """)

    input = Main.inputCheck("Input", :integer)

    case input do
      1 ->
        viewAppointmentRequests(doctorStruct)
        doctorMenu(doctorStruct)

      2 ->
        viewActiveAppointments(doctorStruct)
        doctorMenu(doctorStruct)

      3 ->
        appointmentsMenu(doctorStruct)
        doctorMenu(doctorStruct)

      4 ->
        viewPatients(doctorStruct)
        doctorMenu(doctorStruct)

      5 ->
        setUnavailability(doctorStruct)
        doctorMenu(doctorStruct)

      6 ->
        setTimeranges(doctorStruct)
        doctorMenu(doctorStruct)

      7 -> :ok

      8 ->
        System.halt(0)

      _ ->
        doctorMenu(doctorStruct)
    end
  end

  def viewAppointmentRequests(doctorStruct) do
    appointment_request_list = Appointments.filter_doctor_appointments(doctorStruct.id, ["Pending", "Reschedule"]) |> Main.ensure_list()

    len = length(appointment_request_list)
    back = len + 1
    halt = len + 1

    Main.displayAppointments(appointment_request_list, "Appointment Requests", "Doctor")
    appointment_input = Main.inputCheck("Input", :integer)

    case appointment_input do
      ^back -> :ok
      ^halt -> System.halt(0)

      _ -> confirm_or_cancel_appointment(doctorStruct, appointment_request_list, appointment_input)

    end
  end

  def viewActiveAppointments(doctorStruct) do
    active_appointment_list = Appointments.filter_doctor_appointments(doctorStruct.id, ["Confirmed"]) |> Main.ensure_list()

    len = length(active_appointment_list)
    back = len + 1
    halt = len + 1

    Main.displayAppointments(active_appointment_list, "Upcoming Appointments", "Doctor")
    appointment_input = Main.inputCheck("Input", :integer)

    case appointment_input do
      ^back -> :ok
      ^halt -> System.halt(0)

      _ -> complete_or_cancel_appointment(doctorStruct, active_appointment_list, appointment_input)

    end
  end

  def viewAllAppointments(doctorStruct) do
    appointment_list = Appointments.get_doctor_appointments(doctorStruct.id) |> Main.ensure_list()

    len = length(appointment_list)
    back = len + 1
    halt = len + 1

    Main.displayAppointments(appointment_list, "All Appointments", "Doctor")
    appointment_input = Main.inputCheck("Input", :integer)

    case appointment_input do
      ^back -> :ok
      ^halt -> System.halt(0)
      _ -> delete_or_nil_appointment(doctorStruct, appointment_list, appointment_input)

    end
  end

  def appointmentsEditMenu(doctorStruct) do
    appointment_list = Appointments.get_doctor_appointments(doctorStruct.id) |> Main.ensure_list()

    len = length(appointment_list)
    back = len + 1
    halt = len + 1

    Main.displayAppointments(appointment_list, "All Appointments", "Doctor")
    appointment_input = Main.inputCheck("Input", :integer)

    case appointment_input do
      ^back -> :ok
      ^halt -> System.halt(0)
      _ -> delete_or_nil_appointment(doctorStruct, appointment_list, appointment_input)

    end
  end

  def appointmentsMenu(doctorStruct) do
    IO.write("""
    ╭─────────────────────────────────╮
    | Appointments View               |
    |─────────────────────────────────|
    | (1) All                         |
    | (2) Active                      |
    | (3) Completed                   |
    | (4) Reschedule                  |
    | (5) Pending                     |
    | (6) Cancelled                   |
    |                                 |
    | (7) [Back]                      |
    | (8) [Exit]                      |
    ╰─────────────────────────────────╯
    """)

    appointment_input = Main.inputCheck("Input", :integer)

    case appointment_input do
      1 ->
        appointmentsEditMenu(doctorStruct)
        appointmentsMenu(doctorStruct)

      2 ->
        active_appointment_list = Appointments.filter_doctor_appointments(doctorStruct.id, ["Confirmed"]) |> Main.ensure_list()
        Main.displayAppointments(active_appointment_list, "Active Appointments", "Doctor", false)
        appointmentsMenu(doctorStruct)

      3 ->
        completed_appointment_list = Appointments.filter_doctor_appointments(doctorStruct.id, ["Completed"]) |> Main.ensure_list()
        Main.displayAppointments(completed_appointment_list, "Completed Appointments", "Doctor", false)
        appointmentsMenu(doctorStruct)

      4 ->
        reschedule_appointment_list = Appointments.filter_doctor_appointments(doctorStruct.id, ["Reschedule"]) |> Main.ensure_list()
        Main.displayAppointments(reschedule_appointment_list, "Reschedule Appointments", "Doctor", false)
        appointmentsMenu(doctorStruct)

      5 ->
        pending_appointment_list = Appointments.filter_doctor_appointments(doctorStruct.id, ["Pending"]) |> Main.ensure_list()
        Main.displayAppointments(pending_appointment_list, "Pending Appointments", "Doctor", false)
        appointmentsMenu(doctorStruct)

      6 ->
        cancelled_appointment_list = Appointments.filter_doctor_appointments(doctorStruct.id, ["Cancelled"]) |> Main.ensure_list()
        Main.displayAppointments(cancelled_appointment_list, "Cancelled Appointments", "Doctor", false)
        appointmentsMenu(doctorStruct)

      7 -> :ok

      8 -> System.halt(0)

      _ -> appointmentsMenu(doctorStruct)
    end
  end

  def viewPatients(doctorStruct) do
    patient_list = Appointments.unique_patients(doctorStruct.id) |> Main.ensure_list()

    len = length(patient_list)
    back = len + 1
    halt = len + 1

    Main.displayAppointments(patient_list, "Your Patient List", "Doctor")
    patient_input = Main.inputCheck("Input", :integer)

    case patient_input do
      ^back -> :ok
      ^halt -> System.halt(0)

      _ -> select_or_delete_appointment(doctorStruct, patient_list, patient_input)

    end
  end

  def setUnavailability(doctorStruct) do
    unavailabilities_list = Doctors.list_unavailabilities(doctorStruct.id) |> Main.ensure_list()
    IO.write("""
    ╭─────────────────────────────────────────────────────────────────────────────────────────────────╮
    | Unavailability Dates                                                                            |
    |─────────────────────────────────────────────────────────────────────────────────────────────────|
    """)
    Enum.each(unavailabilities_list, fn unavailable ->
    IO.write("""
    | Date: #{unavailable.date.date}
    |─────────────────────────────────────────────────────────────────────────────────────────────────|
    """)
    end)

    IO.write("""
    |─────────────────────────────────────────────────────────────────────────────────────────────────|
    | (1) Add Date
    | (2) Delete Date
    | (3) Back
    | (4) Halt
    ╰─────────────────────────────────────────────────────────────────────────────────────────────────╯
    """)

    action_input = Main.inputCheck("Input", :integer)

    case action_input do
      1 -> date_input = Main.inputCheck("Enter Date of Unavailability (YYYY-MM-DD)", :date, 1)

        selected_date =
          date_input
          |> Dates.date_exists?()
          |> case do
            false ->
              {:ok, date_struct} = Dates.create_date(%{date: date_input})
              date_struct

            true ->
              {:ok, date_struct} = {:ok, Dates.get_date_by_date(date_input)}
              date_struct
          end

        doctor_appointments = Appointments.filter_date_appointments(doctorStruct.id, selected_date.id, ["Pending", "Reschedule", "Confirmed"])

        if length(doctor_appointments) > 0 do
          IO.write("""
          ╭──────────────────────────────────────────────────────────────────────────────────────╮
          | You have appointments on this date. Unable to create unavailability.                 |
          ╰──────────────────────────────────────────────────────────────────────────────────────╯
          """)
          setUnavailability(doctorStruct)
        else
          Doctors.create_unavailability(%{doctor_id: doctorStruct.id, date_id: selected_date.id})
          IO.write("""
          ╭──────────────────────────────────────────────────────────────────────────────────────╮
          | You have no appointments on this date. Added unavailability.                         |                                                           |
          ╰──────────────────────────────────────────────────────────────────────────────────────╯
          """)
          setUnavailability(doctorStruct)
        end

      2 -> delete_unavailability(doctorStruct, unavailabilities_list)

      3 -> :ok

      4 -> System.halt(0)

      _ -> setUnavailability(doctorStruct)
    end
  end

  #--------------------------------------------------------------------------------------#

  def timeslot_selection(doctorStruct, doctor_timeranges) do
    timerange_list = Doctors.get_available_timeranges(doctor_timeranges)
        len = length(timerange_list)
        back = len + 1
        halt = len + 2

        if len > 0 do
          IO.write("""
          ╭─────────────────────────────────────────────────────────────────────────────────────────────────╮
          | Time Slot Selection (Based on Open hours)
          |─────────────────────────────────────────────────────────────────────────────────────────────────|
          """)
          Enum.with_index(timerange_list)
          |> Enum.each(fn {timerange, index} ->
          IO.write("""
          | (#{index + 1}) #{timerange.start_time}-#{timerange.end_time}
          |─────────────────────────────────────────────────────────────────────────────────────────────────|
          """)
          end)
          IO.write("""
          | (#{back}) Back
          | (#{halt}) Exit
          ╰─────────────────────────────────────────────────────────────────────────────────────────────────╯
          """)

          timerange_input = Main.inputCheck("Input", :integer)

          case timerange_input do
            ^back -> :ok
            ^halt -> System.halt(0)

            _ ->
              case Enum.fetch(timerange_list, timerange_input - 1) do
                {:ok, selected_timerange} ->
                  update_attrs = %{doctor_id: doctorStruct.id, timerange_id: selected_timerange.id}

                  Doctors.add_doctor_timerange(update_attrs)

                  IO.write("""
                  ╭─────────────────────────────────────────────────────────────────────────────────────────────────────╮
                  | #{selected_timerange.start_time} - #{selected_timerange.end_time} has been added to your time slots.
                  ╰─────────────────────────────────────────────────────────────────────────────────────────────────────╯
                  """)
                  setTimeranges(doctorStruct)

                  _ -> timeslot_selection(doctorStruct, doctor_timeranges)
              end
          end
        else

          IO.write("""
          ╭─────────────────────────────────────────────────────────────────────────────────────────────────╮
          | There are no more available time slots.                                                         |
          ╰─────────────────────────────────────────────────────────────────────────────────────────────────╯
          """)
          timeslot_selection(doctorStruct, doctor_timeranges)
        end
  end

  def timeslot_deletion(doctorStruct, doctor_timeranges) do
    len = length(doctor_timeranges)
    back = len + 1
    halt = len + 2

    if len > 0 do

      IO.write("""
      ╭─────────────────────────────────────────────────────────────────────────────────────────────────╮
      | Delete a Time Slot
      |─────────────────────────────────────────────────────────────────────────────────────────────────|
      """)
      Enum.with_index(doctor_timeranges)
      |> Enum.each(fn {timerange, index} ->
      IO.write("""
      | (#{index + 1}) Timeslot
      | #{timerange.start_time} - #{timerange.end_time}
      |─────────────────────────────────────────────────────────────────────────────────────────────────|
      """)
      end)
      IO.write("""
      | (#{back}) Back
      | (#{halt}) Exit
      ╰─────────────────────────────────────────────────────────────────────────────────────────────────╯
      """)

      timerange_input = Main.inputCheck("Input", :integer)

      case timerange_input do
        ^back -> :ok
        ^halt -> System.halt(0)

        _ ->
          case Enum.fetch(doctor_timeranges, timerange_input - 1) do
            {:ok, selected_timerange} ->
              Doctors.delete_doctor_timerange(doctorStruct.id, selected_timerange.id)

              IO.write("""
              ╭─────────────────────────────────────────────────────────────────────────────────────────────────────╮
              | #{selected_timerange.start_time} - #{selected_timerange.end_time} has been removed.
              ╰─────────────────────────────────────────────────────────────────────────────────────────────────────╯
              """)

              setTimeranges(doctorStruct)

              _ -> timeslot_deletion(doctorStruct, doctor_timeranges)
          end
      end
    else

      IO.write("""
      ╭─────────────────────────────────────────────────────────────────────────────────────────────────────╮
      | There are currently no time slots to be deleted.                                                    |
      ╰─────────────────────────────────────────────────────────────────────────────────────────────────────╯
      """)
      timeslot_deletion(doctorStruct, doctor_timeranges)
    end
  end

  def setTimeranges(doctorStruct) do
    doctor_timeranges = Doctors.get_timeranges(doctorStruct) |> Main.ensure_list()

    IO.write("""
    ╭─────────────────────────────────────────────────────────────────────────────────────────────────╮
    | Current Timeslots
    |─────────────────────────────────────────────────────────────────────────────────────────────────|
    """)
    Enum.each(doctor_timeranges, fn timerange ->
    IO.write("""
    | #{timerange.start_time} - #{timerange.end_time}
    |─────────────────────────────────────────────────────────────────────────────────────────────────|
    """)
    end)
    IO.write("""
    |─────────────────────────────────────────────────────────────────────────────────────────────────|
    | (1) Add Timeslot                                                                                |
    | (2) Remove Timeslot                                                                             |
    | (3) Back                                                                                        |
    | (4) Exit                                                                                        |
    ╰─────────────────────────────────────────────────────────────────────────────────────────────────╯
    """)

    action_input = Main.inputCheck("Input", :integer)

    case action_input do
      1 -> timeslot_selection(doctorStruct, doctor_timeranges)

      2 -> timeslot_deletion(doctorStruct, doctor_timeranges)

      3 -> :ok

      4 -> System.halt(0)

      _ -> setTimeranges(doctorStruct)
    end
  end
end
