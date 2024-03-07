defmodule Medappointsys.Main do
  alias Medappointsys.Patientlib, as: PatientLib
  alias Medappointsys.Doctorlib, as: DoctorLib
  alias Medappointsys.Adminlib, as: AdminLib
  alias Medappointsys.Queries.{Patients, Doctors, Admins}
  alias Medappointsys.Schemas.{Patient, Doctor, Admin}
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
      4 -> {%Patient{} = patient, :patients} = (Patients.find_patient("jdelacruz@example.com"))
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

  def inputCheck(prompt, :date) do
    input = IO.gets(prompt <> ": ") |> String.trim()
      case Date.from_iso8601(input) do
      {:ok, date} ->
        ElixirDate.diff(ElixirDate.utc_today(), date)
        |>  abs()
        |>  case do
            14 -> date
             _ -> IO.puts("Invalid date. Please enter a schedule 14 days from now.")
                  inputCheck(prompt, :date)
            end
      {:error, _err} ->
        IO.puts("Invalid date. Please enter a date in the format YYYY-MM-DD.")
        inputCheck(prompt, :date)
      end
  end

    #-----------------------------------------------------------------------------------------------------------------#

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

  # def enclose(string, boxSize, symbol) do

  # end
end
