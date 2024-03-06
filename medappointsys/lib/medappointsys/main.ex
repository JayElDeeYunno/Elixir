defmodule Medappointsys.Main do
  alias Medappointsys.Patientlib, as: PatientLib
  alias Medappointsys.Doctorlib, as: DoctorLib
  alias Medappointsys.Adminlib, as: AdminLib
  alias Medappointsys.Queries.Patients, as: Patients
  alias Medappointsys.Queries.Doctors, as: Doctors
  alias Medappointsys.Queries.Admins, as: Admins

  def main, do: userTypeLoop()

  def userTypeLoop do
    IO.write("""
    ╭───────────────────╮
    | Enter UserType    |
    | (1) Patient       |
    | (2) Doctor        |
    | (3) Admin         |
    | (4) Exit          |
    ╰───────────────────╯
    """)
    userType = inputCheck("Input", :integer)

    case userType do
      1 ->
        PatientLib.patientPrompt(1)
        userTypeLoop()

      2 ->
        # DoctorLib.doctorPrompt(2)
        userTypeLoop()

      3 ->
        AdminLib.adminPrompt(3)
        userTypeLoop()

      4 -> System.halt(0)

    end

  end

  def login(userType) do
    IO.puts("Enter login credentials")
    email = inputCheck("Email", :email)
    pass = inputCheck("Password", :string)

    case userType do

      1 ->
        case Patients.find_patient(email, pass) do
          nil -> {:error, "Incorrect Login"}
          patient -> {:ok, patient}
        end

      2 ->
        case Doctors.find_doctor(email, pass) do
          nil -> {:error, "Incorrect Login"}
          doctor -> {:ok, doctor}
        end

      3 ->
        case Admins.find_admin(email, pass) do
          nil -> {:error, "Incorrect Login"}
          admin -> {:ok, admin}
        end
    end

  end

  def register(1) do
    IO.puts("Enter the following fields")
    email = inputCheck("Email", :email)
    password = inputCheck("Password", :string)
    firstName = inputCheck("FirstName", :alpha)
    lastName = inputCheck("LastName", :alpha)
    gender = inputCheck("Gender", :alpha)
    age = inputCheck("Age", :integer)
    address = inputCheck("Address", :string)
    contactNum = inputCheck("ContactNum", :string)

    # case Patients.find_patient(email, password, firstName, lastName, gender, age, address, contactNum) do
    #   nil ->
    #     case Patients.create_patient(%{
    #       email: email,
    #       password: password,
    #       firstname: firstName,
    #       lastname: lastName,
    #       gender: gender,
    #       age: age,
    #       address: address,
    #       contact_num: contactNum
    #     }) do

    #     end
    #   # IO.puts("Patient Registered")
    #   _ -> IO.puts("Account already exists")
    # end

  end

  def register(2) do
    # no checkers yet
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
      IO.puts("Doctor Registered")
      _ -> IO.puts("Account already exists")
    end

  end

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

  # def enclose(string, boxSize, symbol) do

  # end

end
