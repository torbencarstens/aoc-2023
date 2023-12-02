Code.compiler_options(ignore_module_conflict: true)

defmodule DayTwo do
  def sample do
    "Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue
Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red
Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red
Game 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green"
  end

  def input do
    File.read!("inputs/day02")
  end

  def base do
    DayTwo.input()
    |> String.split("\n")
    |> Enum.filter(fn line -> line != "" end)
    |> Enum.map(fn l -> parse_line(l) end)
  end

  def set_is_possible(set, bag) do
    set
    |> Enum.map(fn {color, count} ->
      bag[color] >= count
    end)
    |> Enum.all?()
  end

  def min_per_color(sets) do
    base = %{"red" => 0, "green" => 0, "blue" => 0}

    Map.keys(base)
    |> Enum.reduce(
      base,
      fn color, acc ->
        counts =
          sets
          |> Enum.map(fn set ->
            set
            |> Enum.filter(fn {c, _} -> c == color end)
          end)
          |> List.flatten()
          |> Enum.map(fn {_, c} -> c end)
          |> Enum.reduce(0, fn c, m -> max(c, m) end)

        %{acc | color => counts}
      end
    )
  end

  def parse_set(s) do
    re = ~r/(\d+)\s+(\w+)/

    Regex.scan(re, s, [:all_but_first])
    |> List.flatten()
    |> Enum.filter(fn e -> !String.contains?(e, " ") end)
    |> Enum.chunk_every(2)
    |> Enum.reduce(%{}, fn [count, color], acc ->
      {count, _} = Integer.parse(count)
      Map.merge(acc, %{color => count})
    end)
  end

  def parse_line(line) do
    # perfection
    {gid, _} = Integer.parse(List.last(String.split(List.first(String.split(line, ": ")), " ")))

    sets =
      line
      |> String.split(": ")
      |> List.last()
      |> String.split("; ")
      |> Enum.map(fn s -> parse_set(s) end)

    %{"game" => gid, "sets" => sets}
  end

  def first do
    DayTwo.base()
    |> Enum.map(fn game ->
      gid = game["game"]
      sets = game["sets"]
      bag = %{"red" => 12, "green" => 13, "blue" => 14}

      case sets |> Enum.all?(fn set -> set_is_possible(set, bag) end) do
        true -> gid
        false -> 0
      end
    end)
    |> List.flatten()
    |> Enum.sum()
  end

  def second do
    DayTwo.base()
    |> Enum.map(fn game ->
      game["sets"]
      |> min_per_color
      |> Enum.reduce(1, fn {_, c}, acc -> c * acc end)
    end)
    |> List.flatten()
    |> Enum.sum()
  end
end

IO.inspect(DayTwo.first())
IO.inspect(DayTwo.second())
