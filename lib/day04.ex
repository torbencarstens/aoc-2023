Code.compiler_options(ignore_module_conflict: true)

defmodule DayFour do
  @moduledoc """
    Solution for AoC day04 (https://adventofcode.com/2023/day/4)
  """

  def sample do
    "Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53
Card 2: 13 32 20 16 61 | 61 30 68 82 17 32 24 19
Card 3:  1 21 53 59 44 | 69 82 63 72 16 21 14  1
Card 4: 41 92 73 84 69 | 59 84 76 51 58  5 54 83
Card 5: 87 83 26 28 32 | 88 30 70 12 93 22 82 36
Card 6: 31 18 13 56 72 | 74 77 10 23 35 67 36 11"
  end

  def input do
    File.read!("inputs/day04")
  end

  def base(use_sample) do
    content = if use_sample, do: sample(), else: input()

    content
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_card/1)
    |> Enum.map(fn %{:winning => winning, :mine => mine} ->
      length(winning -- winning -- mine)
    end)
    |> Enum.with_index(1)
    |> Enum.map(fn {c, i} -> {i, c} end)
  end

  def parse_number_list(numbers) do
    numbers
    |> String.split(" ", trim: true)
    |> Enum.map(&String.to_integer/1)
  end

  def parse_card(line) do
    [_, winning, mine] = String.split(line, [": ", " | "], trim: true)

    %{
      :winning => parse_number_list(winning),
      :mine => parse_number_list(mine)
    }
  end

  def first(use_sample \\ false) do
    base(use_sample)
    |> Enum.map(fn {_, count} -> count end)
    |> Enum.map(&(trunc(2 ** (&1 - 1))))
    |> Enum.sum()
  end

  def second(use_sample \\ false) do
    winnings =
      base(use_sample)
      |> Map.new()

    max_key = Enum.max(winnings |> Map.keys())

    winnings
    |> Enum.sort_by(&elem(&1, 0))
    |> Enum.reduce(
      winnings
      |> Map.new(fn {k, _} -> {k, 1} end),
      fn {cid, length}, running_updates ->
        if length == 0 do
          running_updates
        else
          until = min(cid + length, max_key)

          (cid + 1)..until
          |> Enum.reduce(running_updates, fn index, acc ->
            Map.update!(acc, index, fn current -> current + max(1, running_updates[cid]) end)
          end)
        end
      end
    )
    |> Map.values()
    |> Enum.sum()
  end
end
