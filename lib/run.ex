Code.compiler_options(ignore_module_conflict: true)

defmodule Main do
  def run() do
    DayFive.first(true) |> IO.puts
    DayFour.second(false) |> IO.puts
  end
end

