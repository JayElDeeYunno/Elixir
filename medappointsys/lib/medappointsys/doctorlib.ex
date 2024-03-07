defmodule Medappointsys.Doctorlib do
  alias Medappointsys.Main
  alias Medappointsys.Queries.Appointments
  alias Medappointsys.Queries.Doctors
  alias Medappointsys.Queries.Patients

  def doctorMenu(doctorStruct) do
    IO.write("""
    ╭─────────────────────────────────╮
    | Welcome, Dr. #{doctorStruct.lastname}
    |─────────────────────────────────|
    | (1) Appointment Requests        |
    | (2) Upcoming Appointments       |
    |                                 |
    | (3) View Appointments           |
    | (5) View Patients               |
    |                                 |
    | (6) Set Unavailability          |
    | (7) Set Time Slots              |
    |                                 |
    | (8) [Logout]                    |
    | (9) [Exit]                      |
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
      Appointments.filter_patient_appointments(doctorStruct.id, "Pending")

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
  end

  def viewActiveAppointments(doctorStruct) do
    active_appointment_list =
      Appointments.filter_patient_appointments(doctorStruct.id, "Confirmed")

    len = length(active_appointment_list)
    back = len + 1

    IO.write("""
    ╭─────────────────────────────────────────────────────────────────────────────────────────────────╮
    | Active Appointments
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
          Appointments.get_patient_appointments(doctorStruct.id)

        IO.write("""
        ╭─────────────────────────────────────────────────────────────────────────────────────────────────╮
        | All Appointments
        |─────────────────────────────────────────────────────────────────────────────────────────────────|
        """)

         Enum.each(appointment_list, fn appointment ->
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

      2 ->
        active_appointment_list =
          Appointments.filter_patient_appointments(doctorStruct.id, "Confirmed")

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
          Appointments.filter_patient_appointments(doctorStruct.id, "Completed")

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
          Appointments.filter_patient_appointments(doctorStruct.id, "Confirmed")

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
          Appointments.filter_patient_appointments(doctorStruct.id, "Pending")

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
          Appointments.filter_patient_appointments(doctorStruct.id, "Cancelled")

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
    patient_list = Doctors.get_patients(doctorStruct)

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

              2 ->
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
                    Patients.delete_patient(selected_patient)
                    IO.write("""
                    ╭─────────────────────────────────────────────────────────────────────────────────────────────────╮
                    | The selected patient has been deleted.                                                          |
                    ╰─────────────────────────────────────────────────────────────────────────────────────────────────╯
                    """)

                  2 -> :ok
                  _ -> IO.puts("Invalid Selection")
                end
              _ ->
                IO.puts("Invalid Selection")
            end
        end
    end
  end

  def setUnavailability(doctorStruct) do

  end

  def setTimeranges(doctorStruct) do

  end
end
