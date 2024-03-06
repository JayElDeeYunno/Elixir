defmodule Medappointsys.Doctorlib do
  alias Medappointsys.Main

  def doctorMenu(doctorStruct) do

    IO.write("""
    ╭───────────────────────────────╮
    | Welcome, Dr. #{doctorStruct.lastname}
    |───────────────────────────────|
    | (1) View Appointment Requests |
    | (2) View Reschedule Requests  |
    | (3) View Current Appointments |
    | (4) View All Appointments     |
    | (5) View Patients             |
    | (6) Set Unavailability        |
    | (7) [Logout]                  |
    | (8) [Exit]                    |
    ╰───────────────────────────────╯
    """)
    input = Main.inputCheck("Input", :integer)

    case input do

    1 ->

      doctorMenu(doctorStruct)

    2 ->

      doctorMenu(doctorStruct)

    3 ->

      doctorMenu(doctorStruct)

    4 ->

      doctorMenu(doctorStruct)

    5 ->

      doctorMenu(doctorStruct)

    6 ->

      doctorMenu(doctorStruct)

    7 -> :ok

    8 -> System.halt(0)

     _  -> doctorMenu(doctorStruct)
    end
  end
end
