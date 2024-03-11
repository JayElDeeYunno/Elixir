defmodule Medappointsys.Main do
  alias Medappointsys.Patientlib, as: PatientLib
  alias Medappointsys.Doctorlib, as: DoctorLib
  alias Medappointsys.Adminlib, as: AdminLib
  alias Medappointsys.Queries.Patients, as: Patients
  alias Medappointsys.Queries.Doctors, as: Doctors
  alias Medappointsys.Queries.Admins, as: Admins
  alias Medappointsys.Queries.Dates, as: Dates
  alias Medappointsys.Schemas.Patient, as: Patient
  alias Medappointsys.Schemas.Doctor, as: Doctor
  alias Medappointsys.Schemas.Admin, as: Admin
  alias Date, as: ElixirDate

  def main, do: loginMenu()

  def loginMenu() do
    IO.write("""
    ╭────────────────────────────╮
    | Medical Appointment System |
    |----------------------------|
    | (1) Login                  |
    | (2) Register (Patients)    |
    | (3) Exit                   |
    ╰────────────────────────────╯
    """)
    input = inputCheck("Input", :integer)

    case input do
      1 ->
        result = login()
        case result do
          :error -> :ok
          {:ok, userStruct, :patients} -> PatientLib.patientMenu(userStruct)

          {:ok, userStruct, :doctors} -> DoctorLib.doctorMenu(userStruct)

          {:ok, userStruct, :admins} -> AdminLib.adminMenu(userStruct)
        end

        loginMenu()
      2 -> register_patient()
        loginMenu()

      3 -> System.halt(0)

      #---------------------------------SHORTCUT------------------------------#
      4 -> {%Patient{} = patient, :patients} = (Patients.find_patient("juandelacruz@example.com"))
            PatientLib.patientMenu(patient)
            loginMenu()
      5 -> {%Admin{} = admin, :admins} = (Admins.find_admin("admin@example.com"))
            AdminLib.adminMenu(admin)
            loginMenu()
      6 -> {%Doctor{} = doctor, :doctors} = (Doctors.find_doctor("antoniodizon@example.com"))
            DoctorLib.doctorMenu(doctor)
      loginMenu()
      #-----------------------------------------------------------------------#
      _ -> loginMenu()
    end

  end

  defp login() do
    IO.puts("Enter login credentials")
    email = inputCheck("Email", :email)
    pass = inputCheck("Password", :string)

    case Admins.match_credentials(email) do
      false ->
        IO.puts("Incorrect Email")
        :error
      true ->
        Admins.retrieve_info(email) |> verify(pass)
    end
  end

  defp verify({userStruct, table}, password) do
    if userStruct.password == password do
      IO.puts("Login Successful")
      {:ok, userStruct, table}
    else
      IO.puts("Incorrect Password")
      :error
    end
  end

  #-----------------------------------------------INPUT HANDLERS---------------------------------------------------#
  def inputCheck(prompt, :alphanum) do
    input = IO.gets(prompt <> ": ") |> String.trim()
    if String.match?(input, ~r/^[a-zA-Z0-9]+$/) do
      input
    else
      IO.puts("Invalid input. Please enter alphanumeric characters.")
      inputCheck(prompt, :alphanum)
    end
  end

  def inputCheck(prompt, :integer) do
    input = IO.gets(prompt <> ": ") |> String.trim()
    case Integer.parse(input) do
      {value, _} when is_integer(value) -> value
      _ ->
        IO.puts("Invalid input. Please enter an integer.")
        inputCheck(prompt, :integer)
    end
  end

  def inputCheck(prompt, :alpha) do
    input = IO.gets(prompt <> ": ") |> String.trim()
    if String.match?(input, ~r/^[a-zA-Z]+$/) do
      input
    else
      IO.puts("Invalid input. Please enter alphabet characters.")
      inputCheck(prompt, :alpha)
    end
  end

  def inputCheck(prompt, :email) do
    input = IO.gets(prompt <> ": ") |> String.trim()
    if String.match?(input, ~r/^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/) do
      input
    else
      IO.puts("Invalid input. Please enter a valid email address.")
      inputCheck(prompt, :email)
    end
  end

  def inputCheck(prompt, :string) do
    input = IO.gets(prompt <> ": ") |> String.trim()
    if input != "" do
      input
    else
      IO.puts("Invalid input. Please enter a valid string.")
      inputCheck(prompt, :string)
    end
  end

  def inputCheck(prompt, :date, gap) do
    input = IO.gets(prompt <> ": ") |> String.trim()
      case Date.from_iso8601(input) do
      {:ok, date} ->
        case isFutureDate?(date, gap) do
          {:ok, futureDate} -> futureDate
          :error -> inputCheck(prompt, :date, gap)
        end
      {:error, _err} ->
        IO.puts("Invalid date. Please enter a date in the format YYYY-MM-DD.")
        inputCheck(prompt, :date, gap)
      end
  end

  def isFutureDate?(date, gap) do
    result = ElixirDate.diff(ElixirDate.utc_today(), date) |> abs()
    cond do
      result >= gap -> {:ok, date}
      result < gap -> IO.puts("Invalid date. Please enter a date #{gap} days from now.")
      :error
    end
  end

    #-----------------------------------------------------------------------------------------------------------------#

  def isUnavailableDate(selected_doctor, unavailabilities) do
    date_input = inputCheck("Enter Date (YYYY-MM-DD)", :date, 7)

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
    case Enum.any?(unavailabilities, fn unavailability -> unavailability.date == selected_date end) do
      true ->
        IO.puts("The doctor is unavailable on this date. Please choose another date.")
        isUnavailableDate(selected_doctor, unavailabilities)
      false ->
        selected_date
    end
  end

  def register_doctor() do
    IO.puts("Enter the following fields")
    email = inputCheck("Email", :email)
    password = inputCheck("Password", :string)
    firstName = inputCheck("FirstName", :alpha)
    lastName = inputCheck("LastName", :alpha)
    gender = inputCheck("Gender", :alpha)
    age = inputCheck("Age", :integer)
    address = inputCheck("Address", :string)
    contactNum = inputCheck("ContactNum", :string)
    specialization = inputCheck("Specialization", :alpha)

    case Doctors.find_doctor(email, password, firstName, lastName, gender, age, address, contactNum, specialization) do
      nil -> Doctors.create_doctor(%{
          email: email,
          password: password,
          firstname: firstName,
          lastname: lastName,
          gender: gender,
          age: age,
          address: address,
          contact_num: contactNum,
          specialization: specialization
        })
        IO.puts("Registered Doctor Successfully")

      _ -> IO.puts("Account already exists")

    end
  end

  #

  def register_patient() do
    IO.puts("Enter the following fields")
    email = inputCheck("Email", :email)
    password = inputCheck("Password", :string)
    firstName = inputCheck("FirstName", :alpha)
    lastName = inputCheck("LastName", :alpha)
    gender = inputCheck("Gender", :alpha)
    age = inputCheck("Age", :integer)
    address = inputCheck("Address", :string)
    contactNum = inputCheck("ContactNum", :string)

    case Patients.find_patient(email, password, firstName, lastName, gender, age, address, contactNum) do
      nil -> Patients.create_patient(%{
          email: email,
          password: password,
          firstname: firstName,
          lastname: lastName,
          gender: gender,
          age: age,
          address: address,
          contact_num: contactNum
        })
        IO.puts("Registered Patient Successfully")
      _ -> IO.puts("Account already exists")
    end
  end

   #---------------------------------------------------UTILS-------------------------------------------------#
   def dialogBox(heading, options) do

    len = length(options)
    back = len + 1
    halt = len + 2

    IO.write("""
    ╭───────────────────────────────╮
    | #{heading}
    |===============================|
    """)

    Enum.with_index(options)
    |> Enum.each(fn {option, index} ->
    IO.write("""
    | (#{index + 1}) #{option}
    """)
    end)
    IO.write("""
    | (#{back}) Back
    | (#{halt}) Exit
    ╰───────────────────────────────╯
    """)

    input = inputCheck("Input", :integer)

    cond do
      input == back -> :ok
      input == halt -> System.halt(0)
      input <= len -> input
      input > len -> dialogBox(heading, options)
    end
  end

  def ensure_list(param) when is_list(param), do: param
  def ensure_list(param), do: [param]

  def displayAppointments(appointments, heading, pov, hasIndex \\ true) do

    len = length(appointments)
    back = len + 1
    halt = len + 2

    if hasIndex == true do

      IO.write("""
      ╭─────────────────────────────────────────────────────────────────────────────────────────────────╮
      | #{heading}
      |─────────────────────────────────────────────────────────────────────────────────────────────────|
      """)
      Enum.with_index(appointments)
      |> Enum.each(fn {appointment, index} ->
      names =
        case pov do
          "Patient" -> "#{appointment.doctor.firstname} #{appointment.doctor.lastname}"
          "Doctor" -> "#{appointment.patient.firstname} #{appointment.patient.lastname}"
          "Both" -> "#{appointment.patient.firstname} #{appointment.patient.lastname}, Dr. #{appointment.doctor.lastname}"
        end
      label =
        case pov do
          "Patient" -> "Doctor"
          "Doctor" -> "Patient"
          "Both" -> "Doctor & Patent"
        end
      IO.write("""
      | (#{index + 1})
      | #{label}: #{names}
      | Reason: #{appointment.reason}, Status: #{appointment.status}
      | Date: #{appointment.date.date}, Time: #{appointment.timerange.start_time}-#{appointment.timerange.end_time}
      |─────────────────────────────────────────────────────────────────────────────────────────────────|
      """)
      end)
      IO.write("""
      | (#{back}) Back
      | (#{halt}) Exit
      ╰─────────────────────────────────────────────────────────────────────────────────────────────────╯
      """)
    else
      IO.write("""
      ╭─────────────────────────────────────────────────────────────────────────────────────────────────╮
      | #{heading}
      |─────────────────────────────────────────────────────────────────────────────────────────────────|
      """)
      Enum.each(appointments, fn appointment ->
      names =
        case pov do
          "Patient" -> "#{appointment.doctor.firstname} #{appointment.doctor.lastname}"
          "Doctor" -> "#{appointment.patient.firstname} #{appointment.patient.lastname}"
          "Both" -> "#{appointment.patient.firstname} #{appointment.patient.lastname}, Dr. #{appointment.doctor.lastname}"
        end
      label =
        case pov do
          "Patient" -> "Doctor"
          "Doctor" -> "Patient"
          "Both" -> "Doctor & Patient"
        end
      IO.write("""
      | #{label}: #{names}
      | Reason: #{appointment.reason}, Status: #{appointment.status}
      | Date: #{appointment.date.date}, Time: #{appointment.timerange.start_time}-#{appointment.timerange.end_time},
      |─────────────────────────────────────────────────────────────────────────────────────────────────|
      """)
      end)
      IO.write("""
      ╰─────────────────────────────────────────────────────────────────────────────────────────────────╯
      """)
    end

  end
  # def enclose(string, boxSize, symbol) do

  # end
end
