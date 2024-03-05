defmodule Medappointsys.Doctorlib do
  import Medappointsys.Main
  def doctorPrompt() do
    IO.puts("""
    ╭─────────────────╮
    | Doctor Login    |
    |─────────────────|
    | (1) Login       |
    | (2) [Back]      |
    | (3) [Exit]      |
    ╰─────────────────╯
    """)
    input = IO.gets("") |> String.trim()

    case input do

    "1" ->
      doctorPrompt()

    "2" -> :ok

    "3" -> System.halt(0)

     _  -> doctorPrompt()
    end
  end
end
