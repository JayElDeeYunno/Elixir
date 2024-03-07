defmodule Medappointsys.Patientlib do
  alias Medappointsys.Main
  alias Medappointsys.Queries.Appointments
  alias Medappointsys.Queries.Doctors
  alias Medappointsys.Queries.Dates, as: Dates
  alias Medappointsys.Schemas.{Patient, Doctor, Timerange, Admin, Appointment, Date}
  #
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

      6 ->
        :ok

      7 ->
        System.halt(0)

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
    |> Enum.each(fn %Appointment{
                      status: status,
                      reason: reason,
                      doctor: %Doctor{
                        lastname: doctor_lastname
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
    |> Enum.each(fn {doctor, index} ->
      IO.write("""
      | (#{index + 1}) Dr. #{doctor.firstname} #{doctor.lastname}, #{doctor.specialization}
      """)
    end)

    IO.write("""
    | (#{back}) Back
    ╰───────────────────────────────────────────────────────╯
    """)

    doctor_input = Main.inputCheck("Input", :integer)

    case doctor_input do
      ^back ->
        :ok

      _ ->
        case Enum.fetch(doctorList, doctor_input - 1) do
          {:ok, selected_doctor} ->
            IO.puts(
              "Selected Doctor: Dr. #{selected_doctor.firstname} #{selected_doctor.lastname}"
            )

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


            IO.write("""
            ╭─────────────────────────────────────────────────────────────────────────────────────────────────╮
            | Available Time Slots
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
            |
            ╰─────────────────────────────────────────────────────────────────────────────────────────────────╯
            """)

            timerange_input =
              Main.inputCheck("Select Time Range (Input the corresponding number)", :integer)

            case Enum.fetch(available_timeranges, timerange_input - 1) do
              {:ok, selected_timerange} ->
                IO.puts(
                  "Selected Time Range: #{selected_timerange.start_time} - #{selected_timerange.end_time}"
                )

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

              _ ->
                IO.puts("Invalid time range selection.")
            end

          _ ->
            IO.puts("Invalid selection.")
        end
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
    ╰─────────────────────────────╯
    """)

    reschedule_input = Main.inputCheck("Input", :integer)

    case reschedule_input do
      1 ->
        pending_appointments_list =
          Appointments.filter_patient_appointments(patientStruct.id, ["Pending"])

        len = length(pending_appointments_list)
        back = len + 1

        IO.write("""
        ╭─────────────────────────────────────────────────────────────────────────────────────────────────╮
        | Your Pending Appointments List
        |─────────────────────────────────────────────────────────────────────────────────────────────────|
        """)

        Enum.with_index(pending_appointments_list)
        |> Enum.each(fn {appointment, index} ->
          IO.write("""
          | (#{index + 1}) Appointment
          | Doctor: #{appointment.doctor.firstname} #{appointment.doctor.lastname}, Specialty: #{appointment.doctor.specialization}
          | Date: #{appointment.date.date}, Time: #{appointment.timerange.start_time}-#{appointment.timerange.end_time}, Reason: #{appointment.reason}, Status: #{appointment.status}
          |─────────────────────────────────────────────────────────────────────────────────────────────────|
          """)
        end)

        IO.write("""
        | Note: Rescheduling pending will automatically change the date of the requested appointment
        | (#{back}) Back
        ╰─────────────────────────────────────────────────────────────────────────────────────────────────╯
        """)

        appointment_input = Main.inputCheck("Input", :integer)

        case appointment_input do
          ^back ->
            :ok

          _ ->
            case Enum.fetch(pending_appointments_list, appointment_input - 1) do
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
                | Note: Rescheduling pending will automatically change the date of the requested appointment      |
                ╰─────────────────────────────────────────────────────────────────────────────────────────────────╯
                """)

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
                |                                                                                                 |
                ╰─────────────────────────────────────────────────────────────────────────────────────────────────╯
                """)

                timerange_input =
                  Main.inputCheck("Select Time Range (Input the corresponding number)", :integer)

                case Enum.fetch(available_timeranges, timerange_input - 1) do
                  {:ok, selected_timerange} ->
                    IO.puts(
                      "Selected Time Range: #{selected_timerange.start_time} - #{selected_timerange.end_time}"
                    )

                    update_attrs = %{
                      date_id: selected_date.id,
                      timerange_id: selected_timerange.id,
                      status: "Reschedule"
                    }

                    Appointments.update_appointment(selected_appointment, update_attrs)

                    IO.write("""
                    ╭─────────────────────────────────────────────────────────────────────────────────────────────────╮
                    | Your appointment request has been successfully updated.                                         |
                    ╰─────────────────────────────────────────────────────────────────────────────────────────────────╯
                    """)
                end
            end
        end

      2 ->
        confirmed_appointments_list =
          Appointments.filter_patient_appointments(patientStruct.id, ["Confirmed"])

        len = length(confirmed_appointments_list)
        back = len + 1

        IO.write("""
        ╭─────────────────────────────────────────────────────────────────────────────────────────────────╮
        | Your Active Appointments List                                                                   |
        |─────────────────────────────────────────────────────────────────────────────────────────────────|
        """)

        Enum.with_index(confirmed_appointments_list)
        |> Enum.each(fn {appointment, index} ->
          IO.write("""
          | (#{index + 1}) Appointment
          | Doctor: #{appointment.doctor.firstname} #{appointment.doctor.lastname}, Specialty: #{appointment.doctor.specialization}
          | Date: #{appointment.date.date}, Time: #{appointment.timerange.start_time}-#{appointment.timerange.end_time}, Reason: #{appointment.reason}, Status: #{appointment.status}
          |─────────────────────────────────────────────────────────────────────────────────────────────────|
          """)
        end)

        IO.write("""
        | Note: The confirmed appointment will be rescheduled, requiring confirmation by the doctor.      |
        | (#{back}) Back                                                                                  |
        ╰─────────────────────────────────────────────────────────────────────────────────────────────────╯
        """)

        appointment_input = Main.inputCheck("Input", :integer)

        case appointment_input do
          ^back ->
            :ok

          _ ->
            case Enum.fetch(confirmed_appointments_list, appointment_input - 1) do
              {:ok, selected_appointment} ->
                IO.write("""
                ╭─────────────────────────────────────────────────────────────────────────────────────────────────╮
                | Selected Appointment
                |─────────────────────────────────────────────────────────────────────────────────────────────────|
                """)

                IO.write("""
                | Doctor: #{selected_appointment.doctor.firstname} #{selected_appointment.doctor.lastname}, Specialty: #{selected_appointment.doctor.specialization}
                | Date: #{selected_appointment.date.date}, Time: #{selected_appointment.timerange.start_time}-#{selected_appointment.timerange.end_time}, Reason: #{selected_appointment.reason}, Status: #{selected_appointment.status}
                |─────────────────────────────────────────────────────────────────────────────────────────────────|
                """)

                IO.write("""
                ╰─────────────────────────────────────────────────────────────────────────────────────────────────╯
                """)

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
                |                                                                                                 |
                ╰─────────────────────────────────────────────────────────────────────────────────────────────────╯
                """)

                timerange_input =
                  Main.inputCheck("Select Time Range (Input the corresponding number)", :integer)

                case Enum.fetch(available_timeranges, timerange_input - 1) do
                  {:ok, selected_timerange} ->
                    IO.puts(
                      "Selected Time Range: #{selected_timerange.start_time} - #{selected_timerange.end_time}"
                    )

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
                end
            end
        end

      3 ->
        :ok

      _ ->
        IO.puts("Invalid selection.")
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
      1 ->
        active_appointments_list =
          Appointments.filter_patient_appointments(patientStruct.id, ["Confirmed"])

        len = length(active_appointments_list)
        back = len + 1

        IO.write("""
        ╭─────────────────────────────────────────────────────────────────────────────────────────────────╮
        | Your Active Appointments List
        |─────────────────────────────────────────────────────────────────────────────────────────────────|
        """)

        Enum.with_index(active_appointments_list)
        |> Enum.each(fn {appointment, index} ->
          IO.write("""
          | (#{index + 1}) Appointment
          | Doctor: #{appointment.doctor.firstname} #{appointment.doctor.lastname}, Specialty: #{appointment.doctor.specialization}
          | Date: #{appointment.date.date}, Time: #{appointment.timerange.start_time}-#{appointment.timerange.end_time}, Reason: #{appointment.reason}, Status: #{appointment.status}
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
            case Enum.fetch(active_appointments_list, appointment_input - 1) do
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
                | Note: Rescheduling pending will automatically change the date of the requested appointment      |
                ╰─────────────────────────────────────────────────────────────────────────────────────────────────╯
                """)

                update_attrs = %{status: "Cancelled"}
                Appointments.update_appointment(selected_appointment, update_attrs)

                IO.write("""
                ╭─────────────────────────────────────────────────────────────────────────────────────────────────╮
                | The selected appointment has been cancelled.                                                    |
                ╰─────────────────────────────────────────────────────────────────────────────────────────────────╯
                """)
            end
        end

      2 ->
        pending_appointments_list =
          Appointments.filter_patient_appointments(patientStruct.id, ["Pending"])

        len = length(pending_appointments_list)
        back = len + 1

        IO.write("""
        ╭─────────────────────────────────────────────────────────────────────────────────────────────────╮
        | Your Pending Appointments List
        |─────────────────────────────────────────────────────────────────────────────────────────────────|
        """)

        Enum.with_index(pending_appointments_list)
        |> Enum.each(fn {appointment, index} ->
          IO.write("""
          | (#{index + 1}) Appointment
          | Doctor: #{appointment.doctor.firstname} #{appointment.doctor.lastname}, Specialty: #{appointment.doctor.specialization}
          | Date: #{appointment.date.date}, Time: #{appointment.timerange.start_time}-#{appointment.timerange.end_time}, Reason: #{appointment.reason}, Status: #{appointment.status}
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
            case Enum.fetch(pending_appointments_list, appointment_input - 1) do
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
                | Note: Rescheduling pending will automatically change the date of the requested appointment      |
                ╰─────────────────────────────────────────────────────────────────────────────────────────────────╯
                """)

                update_attrs = %{status: "Cancelled"}
                Appointments.update_appointment(selected_appointment, update_attrs)

                IO.write("""
                  ╭─────────────────────────────────────────────────────────────────────────────────────────────────╮
                  | The selected appointment has been cancelled.                                                    |
                  ╰─────────────────────────────────────────────────────────────────────────────────────────────────╯
                """)
            end
        end

      3 ->
        reschedule_appointments_list =
          Appointments.filter_patient_appointments(patientStruct.id, ["Reschedule"])

        len = length(reschedule_appointments_list)
        back = len + 1

        IO.write("""
        ╭─────────────────────────────────────────────────────────────────────────────────────────────────╮
        | Your Rescedule Appointments List
        |─────────────────────────────────────────────────────────────────────────────────────────────────|
        """)

        Enum.with_index(reschedule_appointments_list)
        |> Enum.each(fn {appointment, index} ->
          IO.write("""
          | (#{index + 1}) Appointment
          | Doctor: #{appointment.doctor.firstname} #{appointment.doctor.lastname}, Specialty: #{appointment.doctor.specialization}
          | Date: #{appointment.date.date}, Time: #{appointment.timerange.start_time}-#{appointment.timerange.end_time}, Reason: #{appointment.reason}, Status: #{appointment.status}
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
            case Enum.fetch(reschedule_appointments_list, appointment_input - 1) do
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
                | Note: Rescheduling pending will automatically change the date of the requested appointment      |
                ╰─────────────────────────────────────────────────────────────────────────────────────────────────╯
                """)

                update_attrs = %{status: "Cancelled"}
                Appointments.update_appointment(selected_appointment, update_attrs)

                IO.write("""
                  ╭─────────────────────────────────────────────────────────────────────────────────────────────────╮
                  | The selected appointment has been cancelled.                                                    |
                  ╰─────────────────────────────────────────────────────────────────────────────────────────────────╯
                """)
            end
        end

      4 ->
        :ok

      _ ->
        IO.puts("Invalid selection.")
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

      7 ->
        :ok

      8 ->
        System.halt(0)

      _ ->
        viewAppoint(patientStruct)
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
    confirmed = Appointments.filter_patient_appointments(patientStruct.id, ["Confirmed"])
    pending = Appointments.filter_patient_appointments(patientStruct.id, ["Pending"])
    completed = Appointments.filter_patient_appointments(patientStruct.id, ["Completed"])
    resched = Appointments.filter_patient_appointments(patientStruct.id, ["Rescheduled"])
    cancelled = Appointments.filter_patient_appointments(patientStruct.id, ["Cancelled"])

    appointInfo = confirmed ++ pending ++ completed ++ resched ++ cancelled

    displayAppoint(patientStruct, appointInfo, "All")
  end

  def activeAppoint(patientStruct) do
    appointInfo = Appointments.filter_patient_appointments(patientStruct.id, ["Confirmed"])
    displayAppoint(patientStruct, appointInfo, "Active")
  end

  def pendingAppoint(patientStruct) do
    appointInfo = Appointments.filter_patient_appointments(patientStruct.id, ["Pending"])
    displayAppoint(patientStruct, appointInfo, "Pending")
  end

  def completedAppoint(patientStruct) do
    appointInfo = Appointments.filter_patient_appointments(patientStruct.id, ["Completed"])
    displayAppoint(patientStruct, appointInfo, "Completed")
  end

  def rescheduledAppoint(patientStruct) do
    appointInfo = Appointments.filter_patient_appointments(patientStruct.id, ["Reschedule"])
    displayAppoint(patientStruct, appointInfo, "Reschedule")
  end

  def cancelledAppoint(patientStruct) do
    appointInfo = Appointments.filter_patient_appointments(patientStruct.id, ["Cancelled"])
    displayAppoint(patientStruct, appointInfo, "Cancelled")
  end
end
