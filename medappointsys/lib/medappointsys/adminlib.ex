defmodule Medappointsys.Adminlib do
  import Medappointsys.Main

  def adminPrompt() do
    IO.puts("""
    ╭─────────────────╮
    | Admin Login     |
    |─────────────────|
    | (1) Login       |
    | (2) [Back]      |
    | (3) [Exit]      |
    ╰─────────────────╯
    """)
    input = IO.gets("") |> String.trim()

    case input do

    "1" ->
      adminPrompt()

    "2" -> :ok

    "3" -> System.halt(0)

     _  -> adminPrompt()
    end
  end
end
