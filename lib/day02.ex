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

  def base(use_sample) do
    content = if use_sample, do: sample(), else: input()

    content
    |> String.split("\n", trim: true)
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
          |> Enum.map(&elem(&1, 1))
          |> Enum.reduce(0, &max/2)

        %{acc | color => counts}
      end
    )
  end

  def parse_set(s) do
    re = ~r/(\d+)\s+(\w+)/

    Regex.scan(re, s, [:all_but_first])
    |> List.flatten()
    |> Enum.filter(&(!String.contains?(&1, " ")))
    |> Enum.chunk_every(2)
    |> Enum.map(fn [count, color] -> {color, String.to_integer(count)} end)
    |> Map.new()
  end

  def parse_line(line) do
    [game, sets] = String.split(line, ": ")
    # perfection
    gid = game |> String.split(" ") |> List.last() |> String.to_integer()

    sets =
      sets
      |> String.split("; ")
      |> Enum.map(&parse_set/1)

    %{:game => gid, :sets => sets}
  end

  def first(use_sample \\ false) do
    bag = %{"red" => 12, "green" => 13, "blue" => 14}

    DayTwo.base(use_sample)
    |> Enum.map(fn %{:game => gid, :sets => sets} ->
      case sets |> Enum.all?(&set_is_possible(&1, bag)) do
        true -> gid
        false -> 0
      end
    end)
    |> List.flatten()
    |> Enum.sum()
  end

  def second(use_sample \\ false) do
    DayTwo.base(use_sample)
    |> Enum.map(fn %{:sets => sets} ->
      sets
      |> min_per_color
      |> Enum.map(&elem(&1, 1))
      |> Enum.reduce(1, &*/2)
    end)
    |> List.flatten()
    |> Enum.sum()
  end
end
