defmodule Medappointsys.Doctorlib do
  alias Medappointsys.Main
  alias Medappointsys.Queries.Appointments
  alias Medappointsys.Queries.Doctors
  alias Medappointsys.Queries.Patients
  alias Medappointsys.Queries.Dates

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
        viewAllAppointments(doctorStruct)
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

      7 ->
        :ok

      8 ->
        System.halt(0)

      _ ->
        doctorMenu(doctorStruct)
    end
  end

  def viewAppointmentRequests(doctorStruct) do
    appointment_request_list =
      Appointments.filter_doctor_appointments(doctorStruct.id, ["Pending", "Reschedule"])

    IO.inspect(appointment_request_list)
    len = length(appointment_request_list)
    back = len + 1

    IO.write("""
    ╭─────────────────────────────────────────────────────────────────────────────────────────────────╮
    | Appointment Requests
    |─────────────────────────────────────────────────────────────────────────────────────────────────|
    """)

    Enum.with_index(appointment_request_list)
    |> Enum.each(fn {appointment, index} ->
      IO.write("""
      | (#{index + 1}) Appointment
      | Patient: #{appointment.patient.firstname} #{appointment.patient.lastname}
      | Reason: #{appointment.reason}, Status: #{appointment.status}
      | Date: #{appointment.date.date}, Time: #{appointment.timerange.start_time}-#{appointment.timerange.end_time},
      |─────────────────────────────────────────────────────────────────────────────────────────────────|
      """)
    end)

    IO.write("""
    | (#{back}) Back
    ╰─────────────────────────────────────────────────────────────────────────────────────────────────╯
    """)

    appointment_input = Main.inputCheck("Input", :integer)

    case appointment_input do
      ^back ->
        :ok

      _ ->
        case Enum.fetch(appointment_request_list, appointment_input - 1) do
          {:ok, selected_appointment} ->
            IO.write("""
            ╭─────────────────────────────────────────────────────────────────────────────────────────────────╮
            | Selected Appointment                                                                            |
            |─────────────────────────────────────────────────────────────────────────────────────────────────|
            """)

            IO.write("""
            | Doctor: #{selected_appointment.doctor.firstname} #{selected_appointment.doctor.lastname}, Specialty: #{selected_appointment.doctor.specialization}
            | Date: #{selected_appointment.date.date}, Time: #{selected_appointment.timerange.start_time}-#{selected_appointment.timerange.end_time}, Reason: #{selected_appointment.reason}, Status: #{selected_appointment.status}
            |─────────────────────────────────────────────────────────────────────────────────────────────────|
            """)

            IO.write("""
            |                                                                                                 |
            ╰─────────────────────────────────────────────────────────────────────────────────────────────────╯
            """)

            IO.write("""
            ╭───────────────────────────────╮
            | Action                        |
            |===============================|
            | (1) Confirm Appointment       |
            | (2) Cancel Appointment        |
            | (3) [Back]                    |
            ╰───────────────────────────────╯
            """)

            status_input = Main.inputCheck("Input", :integer)

            case status_input do
              1 ->
                update_attrs = %{status: "Confirmed"}
                Appointments.update_appointment(selected_appointment, update_attrs)

                IO.write("""
                ╭─────────────────────────────────────────────────────────────────────────────────────────────────╮
                | The selected appointment has been confirmed. The patient will be notified.                                             |
                ╰─────────────────────────────────────────────────────────────────────────────────────────────────╯
                """)

              2 ->
                update_attrs = %{status: "Cancelled"}
                Appointments.update_appointment(selected_appointment, update_attrs)

              3 ->
                :ok

              _ ->
                IO.puts("Invalid selection")
            end
        end
    end
  end

  @spec viewActiveAppointments(atom() | %{:id => any(), optional(any()) => any()}) :: :ok
  def viewActiveAppointments(doctorStruct) do
    active_appointment_list =
      Appointments.filter_doctor_appointments(doctorStruct.id, ["Confirmed"])

    len = length(active_appointment_list)
    back = len + 1

    IO.write("""
    ╭─────────────────────────────────────────────────────────────────────────────────────────────────╮
    | Upcoming Appointments
    |─────────────────────────────────────────────────────────────────────────────────────────────────|
    """)

    Enum.with_index(active_appointment_list)
    |> Enum.each(fn {appointment, index} ->
      IO.write("""
      | (#{index + 1}) Appointment
      | Patient: #{appointment.patient.firstname} #{appointment.patient.lastname}
      | Reason: #{appointment.reason}, Status: #{appointment.status}
      | Date: #{appointment.date.date}, Time: #{appointment.timerange.start_time}-#{appointment.timerange.end_time},
      |─────────────────────────────────────────────────────────────────────────────────────────────────|
      """)
    end)

    IO.write("""
    | (#{back}) Back
    ╰─────────────────────────────────────────────────────────────────────────────────────────────────╯
    """)

    appointment_input = Main.inputCheck("Input", :integer)

    case appointment_input do
      ^back ->
        :ok

      _ ->
        case Enum.fetch(active_appointment_list, appointment_input - 1) do
          {:ok, selected_appointment} ->
            IO.write("""
            ╭─────────────────────────────────────────────────────────────────────────────────────────────────╮
            | Selected Appointment
            |─────────────────────────────────────────────────────────────────────────────────────────────────|
            """)

            IO.write("""
            | Patient: #{selected_appointment.patient.firstname} #{selected_appointment.patient.lastname}
            | Date: #{selected_appointment.date.date}, Time: #{selected_appointment.timerange.start_time}-#{selected_appointment.timerange.end_time},
            | Reason: #{selected_appointment.reason}, Status: #{selected_appointment.status}
            |─────────────────────────────────────────────────────────────────────────────────────────────────|
            """)

            IO.write("""
            ╰─────────────────────────────────────────────────────────────────────────────────────────────────╯
            """)

            IO.write("""
            ╭───────────────────────────────╮
            | Action                        |
            |===============================|
            | (1) Mark as Completed         |
            | (2) Cancel Appointment        |
            | (3) [Back]                    |
            ╰───────────────────────────────╯
            """)

            status_input = Main.inputCheck("Input", :integer)

            case status_input do
              1 ->
                update_attrs = %{status: "Completed"}
                Appointments.update_appointment(selected_appointment, update_attrs)

                IO.write("""
                  ╭─────────────────────────────────────────────────────────────────────────────────────────────────╮
                  | The selected appointment has been marked Completed.                                             |
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

              3 ->
                :ok

              _ ->
                IO.puts("Invalid selection.")
            end
        end
    end
  end

  def viewAllAppointments(doctorStruct) do
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
    ╰─────────────────────────────────╯
    """)

    appointment_input = Main.inputCheck("Input", :integer)

    case appointment_input do
      1 ->
        appointment_list =
          Appointments.get_doctor_appointments(doctorStruct.id)

        len = length(appointment_list)
        back = len + 1

        IO.write("""
        ╭─────────────────────────────────────────────────────────────────────────────────────────────────╮
        | All Appointments
        |─────────────────────────────────────────────────────────────────────────────────────────────────|
        """)

        Enum.with_index(appointment_list)
        |> Enum.each(fn {appointment, index} ->
          IO.write("""
          | (#{index + 1}) Patient
          | Name: #{appointment.patient.firstname} #{appointment.patient.lastname}
          | Reason: #{appointment.reason}, Status: #{appointment.status}
          | Date: #{appointment.date.date}, Time: #{appointment.timerange.start_time}-#{appointment.timerange.end_time},
          |─────────────────────────────────────────────────────────────────────────────────────────────────|
          """)
        end)

        IO.write("""
        | (#{back}) Back
        ╰─────────────────────────────────────────────────────────────────────────────────────────────────╯
        """)

        appointment_input = Main.inputCheck("Input", :integer)

        case appointment_input do
          _ ->
            case Enum.fetch(appointment_list, appointment_input - 1) do
              {:ok, selected_appointment} ->
                IO.write("""
                ╭─────────────────────────────────────────────────────────────────────────────────────────────────╮
                | Selected Appointment                                                                            |
                |─────────────────────────────────────────────────────────────────────────────────────────────────|
                """)

                IO.write("""
                | Doctor: #{selected_appointment.doctor.firstname} #{selected_appointment.doctor.lastname}, Specialty: #{selected_appointment.doctor.specialization}
                | Date: #{selected_appointment.date.date}, Time: #{selected_appointment.timerange.start_time}-#{selected_appointment.timerange.end_time}, Reason: #{selected_appointment.reason}, Status: #{selected_appointment.status}
                |─────────────────────────────────────────────────────────────────────────────────────────────────|
                """)

                IO.write("""
                |                                                                                                 |
                ╰─────────────────────────────────────────────────────────────────────────────────────────────────╯
                """)

                IO.write("""
                ╭─────────────────────────────────╮
                | Action                          |
                |─────────────────────────────────|
                | (1) Delete                      |
                | (2) [Back]                      |
                ╰─────────────────────────────────╯
                """)

                action_input = Main.inputCheck("Input", :integer)

                case action_input do
                  1 ->
                    Appointments.delete_appointment(selected_appointment)

                  2 ->
                    :ok

                  _ ->
                    "Invalid Selection"
                end
            end
        end

      2 ->
        active_appointment_list =
          Appointments.filter_doctor_appointments(doctorStruct.id, ["Confirmed"])

        IO.write("""
        ╭─────────────────────────────────────────────────────────────────────────────────────────────────╮
        | Active Appointments
        |─────────────────────────────────────────────────────────────────────────────────────────────────|
        """)

        Enum.each(active_appointment_list, fn appointment ->
          IO.write("""
          | Patient: #{appointment.patient.firstname} #{appointment.patient.lastname}
          | Reason: #{appointment.reason}, Status: #{appointment.status}
          | Date: #{appointment.date.date}, Time: #{appointment.timerange.start_time}-#{appointment.timerange.end_time},
          |─────────────────────────────────────────────────────────────────────────────────────────────────|
          """)
        end)

        IO.write("""
        | (1) Back
        ╰─────────────────────────────────────────────────────────────────────────────────────────────────╯
        """)

      3 ->
        completed_appointment_list =
          Appointments.filter_doctor_appointments(doctorStruct.id, ["Completed"])

        IO.write("""
        ╭─────────────────────────────────────────────────────────────────────────────────────────────────╮
        | Completed Appointments
        |─────────────────────────────────────────────────────────────────────────────────────────────────|
        """)

        Enum.each(completed_appointment_list, fn appointment ->
          IO.write("""
          | Patient: #{appointment.patient.firstname} #{appointment.patient.lastname}
          | Reason: #{appointment.reason}, Status: #{appointment.status}
          | Date: #{appointment.date.date}, Time: #{appointment.timerange.start_time}-#{appointment.timerange.end_time},
          |─────────────────────────────────────────────────────────────────────────────────────────────────|
          """)
        end)

        IO.write("""
        | (1) Back
        ╰─────────────────────────────────────────────────────────────────────────────────────────────────╯
        """)

      4 ->
        reschedule_appointment_list =
          Appointments.filter_doctor_appointments(doctorStruct.id, ["Reschedule"])

        IO.write("""
        ╭─────────────────────────────────────────────────────────────────────────────────────────────────╮
        | Reschedule Appointments
        |─────────────────────────────────────────────────────────────────────────────────────────────────|
        """)

        Enum.each(reschedule_appointment_list, fn appointment ->
          IO.write("""
          | Patient: #{appointment.patient.firstname} #{appointment.patient.lastname}
          | Reason: #{appointment.reason}, Status: #{appointment.status}
          | Date: #{appointment.date.date}, Time: #{appointment.timerange.start_time}-#{appointment.timerange.end_time},
          |─────────────────────────────────────────────────────────────────────────────────────────────────|
          """)
        end)

        IO.write("""
        | (1) Back
        ╰─────────────────────────────────────────────────────────────────────────────────────────────────╯
        """)

      5 ->
        pending_appointment_list =
          Appointments.filter_doctor_appointments(doctorStruct.id, ["Pending"])

        IO.write("""
        ╭─────────────────────────────────────────────────────────────────────────────────────────────────╮
        | Pending Appointments
        |─────────────────────────────────────────────────────────────────────────────────────────────────|
        """)

        Enum.each(pending_appointment_list, fn appointment ->
          IO.write("""
          | Patient: #{appointment.patient.firstname} #{appointment.patient.lastname}
          | Reason: #{appointment.reason}, Status: #{appointment.status}
          | Date: #{appointment.date.date}, Time: #{appointment.timerange.start_time}-#{appointment.timerange.end_time},
          |─────────────────────────────────────────────────────────────────────────────────────────────────|
          """)
        end)

        IO.write("""
        | (1) Back
        ╰─────────────────────────────────────────────────────────────────────────────────────────────────╯
        """)

      6 ->
        cancelled_appointment_list =
          Appointments.filter_doctor_appointments(doctorStruct.id, ["Cancelled"])

        IO.write("""
        ╭─────────────────────────────────────────────────────────────────────────────────────────────────╮
        | Cancelled Appointments
        |─────────────────────────────────────────────────────────────────────────────────────────────────|
        """)

        Enum.each(cancelled_appointment_list, fn appointment ->
          IO.write("""
          | Patient: #{appointment.patient.firstname} #{appointment.patient.lastname}
          | Reason: #{appointment.reason}, Status: #{appointment.status}
          | Date: #{appointment.date.date}, Time: #{appointment.timerange.start_time}-#{appointment.timerange.end_time},
          |─────────────────────────────────────────────────────────────────────────────────────────────────|
          """)
        end)

        IO.write("""
        | (1) Back
        ╰─────────────────────────────────────────────────────────────────────────────────────────────────╯
        """)

      7 ->
        :ok

      _ ->
        IO.puts("Invalid selection.")
    end
  end

  def viewPatients(doctorStruct) do
    patient_list = Appointments.unique_patients(doctorStruct)

    len = length(patient_list)
    back = len + 1

    IO.write("""
    ╭─────────────────────────────────────────────────────────────────────────────────────────────────╮
    | Your Patients
    |─────────────────────────────────────────────────────────────────────────────────────────────────|
    """)

    Enum.with_index(patient_list)
    |> Enum.each(fn {patient, index} ->
      IO.write("""
      | (#{index + 1}) Patient
      | Name: #{patient.firstname} #{patient.lastname}
      | Gender: #{patient.age}, Age: #{patient.address}
      | Address: #{patient.address}, Contact#: #{patient.contact_num}
      |─────────────────────────────────────────────────────────────────────────────────────────────────|
      """)
    end)

    IO.write("""
    | (#{back}) Back
    ╰─────────────────────────────────────────────────────────────────────────────────────────────────╯
    """)

    patient_input = Main.inputCheck("Input", :integer)

    case patient_input do
      ^back ->
        :ok

      _ ->
        case Enum.fetch(patient_list, patient_input - 1) do
          {:ok, selected_patient} ->
            IO.write("""
            ╭─────────────────────────────────────────────────────────────────────────────────────────────────╮
            | Selected Patient
            |─────────────────────────────────────────────────────────────────────────────────────────────────|
            """)

            IO.write("""
            | Name: #{selected_patient.firstname} #{selected_patient.lastname}
            | Gender: #{selected_patient.age}, Age: #{selected_patient.address}
            | Address: #{selected_patient.address}, Contact#: #{selected_patient.contact_num}
            |─────────────────────────────────────────────────────────────────────────────────────────────────|
            ╰─────────────────────────────────────────────────────────────────────────────────────────────────╯
            """)

            IO.write("""
            ╭─────────────────────────────────╮
            | Action                          |
            |─────────────────────────────────|
            | (1) Appointments                |
            | (2) Delete                      |
            | (3) [Back]                      |
            ╰─────────────────────────────────╯
            """)

            action_input = Main.inputCheck("Input", :integer)

            case action_input do
              1 ->
                patient_appointments_list =
                  Appointments.get_patient_appointments(selected_patient.id)

                IO.write("""
                ╭─────────────────────────────────────────────────────────────────────────────────────────────────╮
                | All Appointments
                |─────────────────────────────────────────────────────────────────────────────────────────────────|
                """)

                Enum.each(patient_appointments_list, fn appointment ->
                  IO.puts("""
                  | Patient: #{appointment.patient.firstname} #{appointment.patient.lastname}
                  | Reason: #{appointment.reason}, Status: #{appointment.status}
                  | Date: #{appointment.date.date}, Time: #{appointment.timerange.start_time}-#{appointment.timerange.end_time}
                  |─────────────────────────────────────────────────────────────────────────────────────────────────|
                  """)
                end)

                IO.write("""
                | (1) Back
                ╰─────────────────────────────────────────────────────────────────────────────────────────────────╯
                """)

                _input = Main.inputCheck("Input", :integer)

              2 ->
                IO.write("""
                ╭─────────────────────────────────────────────────────────────────────────────────────────────────╮
                | Current Time
                |─────────────────────────────────────────────────────────────────────────────────────────────────|
                """)

                IO.write("""
                | Name: #{selected_patient.firstname} #{selected_patient.lastname}
                | Gender: #{selected_patient.age}, Age: #{selected_patient.address}
                | Address: #{selected_patient.address}, Contact#: #{selected_patient.contact_num}
                |─────────────────────────────────────────────────────────────────────────────────────────────────|
                ╰─────────────────────────────────────────────────────────────────────────────────────────────────╯
                """)

                IO.write("""
                ╭─────────────────────────────────────────────╮
                | CONFIRM DELETION                            |
                | ** All appointments associated with this    |
                | patient will be deleted as well **          |
                |─────────────────────────────────────────────|
                | (1) Confirm                                 |
                | (2) Decline                                 |
                ╰─────────────────────────────────────────────╯
                """)

                confirm_input = Main.inputCheck("Input", :integer)

                case confirm_input do
                  1 ->
                    Appointments.get_patient_appointments(selected_patient.id)
                    |> Enum.each(&Appointments.delete_appointment/1)

                    Patients.delete_patient(selected_patient)

                    IO.write("""
                    ╭─────────────────────────────────────────────────────────────────────────────────────────────────╮
                    | The selected patient and their appointemnts has been deleted.                                   |
                    ╰─────────────────────────────────────────────────────────────────────────────────────────────────╯
                    """)

                  2 ->
                    :ok

                  _ ->
                    IO.puts("Invalid Selection")
                end

              _ ->
                IO.puts("Invalid Selection")
            end
        end
    end
  end

  def setUnavailability(doctorStruct) do
    unavailabilities = Doctors.list_unavailabilities(doctorStruct.id)
    IO.inspect(unavailabilities)
    IO.write("""
    ╭─────────────────────────────────────────────────────────────────────────────────────────────────╮
    | Unavailable Dates                                                                                     |
    |─────────────────────────────────────────────────────────────────────────────────────────────────|
    """)
    Enum.each(unavailabilities, fn unavailable ->
      IO.write("""
      | Date: #{unavailable.date.date}
      |─────────────────────────────────────────────────────────────────────────────────────────────────|
      """)
    end)

    IO.write("""
    | (1) Add Date
    | (2) Delete Date
    | (3) Back
    ╰─────────────────────────────────────────────────────────────────────────────────────────────────╯
    """)

    action_input = Main.inputCheck("Input", :integer)

case action_input do
  1 ->
    date_input = Main.inputCheck("Enter Reschedule Date (YYYY-MM-DD)", :date, 1)

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
    IO.inspect(doctor_appointments)

    if length(doctor_appointments) > 0 do
      IO.write("""
      ╭──────────────────────────────────────────────────────────────────────────────────────╮
      | You have appointments on this date. Unable to create unavailability.                 |
      ╰──────────────────────────────────────────────────────────────────────────────────────╯
      """)
    else
      Doctors.create_unavailability(%{doctor_id: doctorStruct.id, date_id: selected_date.id})
      IO.write("""
      ╭──────────────────────────────────────────────────────────────────────────────────────╮
      | Added Unavailable Date                                                               |
      ╰──────────────────────────────────────────────────────────────────────────────────────╯
      """)
    end
  2 ->
    len = length(unavailabilities)
    back = len + 1

    IO.write("""
    ╭─────────────────────────────────────────────────────────────────────────────────────────────────╮
    | Select Date to Delete                                                                                    |
    |─────────────────────────────────────────────────────────────────────────────────────────────────|
    """)
    Enum.with_index(unavailabilities)
    |> Enum.each(fn {unavailable, index} ->
      IO.write("""
      | (#{index + 1}) Appointment
      | Date: #{unavailable.date.date}
      """)
    end)
    IO.write("""
    | (#{back}) Back
    ╰─────────────────────────────────────────────────────────────────────────────────────────────────╯
    """)

    delete_input = Main.inputCheck("Input", :integer)

    case delete_input do
      ^back ->
        :ok
      _ ->
        case Enum.fetch(unavailabilities, delete_input - 1) do
          {:ok, selected_unavailability} ->
            Doctors.delete_unavailability(selected_unavailability)

            IO.write("""
            ╭──────────────────────────────────────────────────────────────────────────────────────╮
            | Unavailable date has been removed.                                                   |
            ╰──────────────────────────────────────────────────────────────────────────────────────╯
            """)
          _ ->
            IO.write("Invalid Input")
        end
    end

  3 -> :ok

  _ -> IO.write("Invalid Selection")
end

  end

  def setTimeranges(doctorStruct) do
    doctor_timeranges = Doctors.get_timeranges(doctorStruct)
    IO.inspect(doctor_timeranges)

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
    | (1) Add Timeslot
    | (2) Remove Timeslot
    | (3) Back
    ╰─────────────────────────────────────────────────────────────────────────────────────────────────╯
    """)

    action_input = Main.inputCheck("Input", :integer)

    case action_input do
      1 ->
        timerange_list = Doctors.get_available_timeranges(doctor_timeranges)
        IO.inspect(timerange_list)
        len = length(timerange_list)
        back = len + 1

        IO.write("""
        ╭─────────────────────────────────────────────────────────────────────────────────────────────────╮
        | Time Slot Selection (Based on Open hours)
        |─────────────────────────────────────────────────────────────────────────────────────────────────|
        """)
        Enum.with_index(timerange_list)
        |> Enum.each(fn {timerange, index} ->
          IO.write("""
          | (#{index + 1}}) Timeslot
          | #{timerange.start_time}-#{timerange.end_time}
          |─────────────────────────────────────────────────────────────────────────────────────────────────|
          """)
        end)
        IO.write("""
        | (#{back}) Back
        ╰─────────────────────────────────────────────────────────────────────────────────────────────────╯
        """)

        timerange_input = Main.inputCheck("Input", :integer)

        case timerange_input do
          ^back ->
            :ok

          _ ->
            case Enum.fetch(timerange_list, timerange_input - 1) do
              {:ok, selected_timerange} ->
                update_attrs = %{doctor_id: doctorStruct.id, timerange_id: selected_timerange.id}

                Doctors.add_doctor_timerange(update_attrs)

                IO.write("""
                ╭─────────────────────────────────────────────────────────────────────────────────────────────────────╮
                | #{selected_timerange.start_time} - #{selected_timerange.end_time} has been added to your time slots.|
                ╰─────────────────────────────────────────────────────────────────────────────────────────────────────╯
                """)
            end
        end

      2 ->
        len = length(doctor_timeranges)
        back = len + 1

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
        ╰─────────────────────────────────────────────────────────────────────────────────────────────────╯
        """)

        timerange_input = Main.inputCheck("Input", :integer)

        case timerange_input do
          ^back ->
            :ok

          _ ->
            case Enum.fetch(doctor_timeranges, timerange_input - 1) do
              {:ok, selected_timerange} ->
                Doctors.delete_doctor_timerange(doctorStruct.id, selected_timerange.id)

                IO.write("""
                ╭─────────────────────────────────────────────────────────────────────────────────────────────────────╮
                | #{selected_timerange.start_time} - #{selected_timerange.end_time} has been removed.                 |
                ╰─────────────────────────────────────────────────────────────────────────────────────────────────────╯
                """)
            end
        end

      3 ->
        :ok

      _ ->
        IO.puts("Invalid Input")
    end
  end
end
