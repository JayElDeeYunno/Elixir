defmodule Medappointsys.Main do
  alias Medappointsys.Patientlib, as: PatientLib
  alias Medappointsys.Doctorlib, as: DoctorLib
  alias Medappointsys.Adminlib, as: AdminLib
  alias Medappointsys.Queries.Patients, as: Patients
  alias Medappointsys.Queries.Doctors, as: Doctors
  alias Medappointsys.Queries.Admins, as: Admins

  def main do
    userTypeLoop()
  end

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
    userType = IO.gets("") |> String.trim()

    case userType do
      "1" ->
        PatientLib.patientPrompt(1)
        userTypeLoop()

      "2" ->
        # DoctorLib.doctorPrompt(2)
        userTypeLoop()

      "3" ->
        # AdminLib.adminPrompt(3)
        userTypeLoop()

      "4" -> System.halt(0)

       _  -> userTypeLoop()
    end
  end

  def login(userType) do
    IO.puts("Enter login credentials")
    email = IO.gets("Email: ") |> String.trim()
    pass = IO.gets("Password: ") |> String.trim()

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
    # no checkers yet
    IO.puts("Enter the following fields")
    email = IO.gets("Email: ") |> String.trim()
    password = IO.gets("Password: ") |> String.trim()
    firstName = IO.gets("FirstName: ") |> String.trim()
    lastName = IO.gets("LastName: ") |> String.trim()
    gender = IO.gets("Gender: ") |> String.trim()
    age = IO.gets("Age: ") |> String.trim() |> String.to_integer()
    address = IO.gets("Address: ") |> String.trim()
    contactNum = IO.gets("ContactNum: ") |> String.trim()

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
      IO.puts("Patient Registered")
      _ -> IO.puts("Account already exists")
    end
  end

  def register(2) do
    # no checkers yet
    IO.puts("Enter the following fields")
    email = IO.gets("Email: ")
    password = IO.gets("Password: ")
    firstName = IO.gets("FirstName: ")
    lastName = IO.gets("LastName: ")
    gender = IO.gets("Gender: ")
    age = IO.gets("Age: ") |> String.to_integer()
    address = IO.gets("Address: ")
    contactNum = IO.gets("ContactNum: ")
    specialization = IO.gets("Specialization: ")

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

  # def enclose(string, boxSize, symbol) do

  # end

end
