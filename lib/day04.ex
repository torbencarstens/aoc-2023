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
    |> String.split("\n")
    |> Enum.filter(fn line -> line != "" end)
  end

  def parse_number_list(numbers) do
    numbers
    |> String.split(" ")
    |> Enum.filter(fn s -> s != "" end)
    |> Enum.map(&Integer.parse/1)
    |> Enum.map(fn {v, _} -> v end)
  end

  def parse_card(line) do
    [card_info, numbers] = String.split(line, ": ")
    [winning, mine] = String.split(numbers, " | ")

    {card_id, _} = Integer.parse(Enum.at(Regex.split(~r/\s+/, card_info), 1))

    %{
      :card_id => card_id,
      :winning => parse_number_list(winning),
      :mine => parse_number_list(mine)
    }
  end

  def calculate_card_points([]), do: 0
  def calculate_card_points([_]), do: 1
  def calculate_card_points([_ | tail]), do: 2 * calculate_card_points(tail)

  def first(use_sample \\ false) do
    base(use_sample)
    |> Enum.map(&parse_card/1)
    |> Enum.map(fn %{:winning => winning, :mine => mine} ->
      [winning, mine] |> Enum.map(&MapSet.new/1)
    end)
    |> Enum.map(fn [winning, mine] -> MapSet.intersection(winning, mine) end)
    |> Enum.map(&MapSet.to_list/1)
    |> Enum.map(&calculate_card_points/1)
    |> Enum.sum()
  end

  def second(use_sample \\ false) do
    winnings =
      base(use_sample)
      |> Enum.map(&parse_card/1)
      |> Enum.map(fn %{:card_id => cid, :winning => winning, :mine => mine} ->
        [winning, mine] = [winning, mine] |> Enum.map(&MapSet.new/1)
        [cid, winning, mine]
      end)
      |> Enum.map(fn [cid, winning, mine] -> [cid, MapSet.intersection(winning, mine)] end)
      |> Enum.reduce(%{}, fn [cid, won], acc ->
        Map.merge(acc, %{cid => MapSet.to_list(won) |> length})
      end)

    result =
      Map.new(
        winnings
        |> Enum.map(fn {k, _} -> {k, 1} end)
      )

    max_key = Enum.max(winnings |> Map.keys())

    winnings
    |> Enum.sort(fn {k, _}, {k2, _} -> k < k2 end)
    |> Enum.reduce(result, fn {cid, length}, acco ->
      if length == 0 do
        acco
      else
        until = min(cid + length, max_key)

        (cid + 1)..until
        |> Enum.reduce(acco, fn index, acc ->
          if index > max_key do
            acc
          else
            Map.update!(acc, index, fn current -> current + max(1, acco[cid]) end)
          end
        end)
      end
    end)
    |> Map.values()
    |> Enum.sum()
  end
end
