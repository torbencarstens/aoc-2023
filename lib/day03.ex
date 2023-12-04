Code.compiler_options(ignore_module_conflict: true)
import Vector

defmodule Schematic do
  @enforce_keys [:lines]
  defstruct [:lines]

  def init(lines), do: %Schematic{lines: lines}

  def directions do
    [
      %Vector{x: -1, y: -1},
      %Vector{x: -1, y: 0},
      %Vector{x: -1, y: 1},
      %Vector{x: 0, y: -1},
      %Vector{x: 0, y: 1},
      %Vector{x: 1, y: -1},
      %Vector{x: 1, y: 0},
      %Vector{x: 1, y: 1}
    ]
  end

  def at(schematic, point) do
    line = Enum.at(schematic.lines, point.y)

    case is_nil(line) do
      true -> nil
      false -> Enum.at(line, point.x)
    end
  end

  def neighbor_points(vector) do
    directions()
    |> Enum.map(&(vector +++ &1))
    |> Enum.filter(&(!Vector.has_negative(&1)))
  end

  def neighbors(schematic, vector) do
    neighbor_points(vector)
    |> Enum.map(&Schematic.at(schematic, &1))
    |> Enum.filter(&(!is_nil(&1)))
  end

  def is_number(c) do
    Regex.match?(~r/[0-9]/, c)
  end

  def find_numbers_in_line(line, lineno) do
    s = Enum.join(line, "")

    Regex.scan(~r/[0-9]+/, s, return: :index)
    |> Enum.map(&hd/1)
    |> Enum.map(fn {si, length} ->
      %{:start => %Vector{x: si, y: lineno}, :end => %Vector{x: si + length - 1, y: lineno}}
    end)
  end

  def find_numbers(schematic) do
    schematic.lines
    |> Enum.with_index(&find_numbers_in_line/2)
    |> Enum.filter(&(&1 != []))
    |> List.flatten()
  end

  def get_number(schematic, start, en, y) do
    s =
      start..en
      |> Enum.map(&Schematic.at(schematic, %Vector{x: &1, y: y}))
      |> Enum.join("")

    String.to_integer(s)
  end

  def find_gears(schematic) do
    schematic.lines
    |> Enum.map(&Enum.join(&1, ""))
    |> Enum.map(&Regex.scan(~r/[*]/, &1, return: :index))
    |> Enum.with_index()
    |> Enum.filter(&(elem(&1, 1) != []))
    |> Enum.map(fn {l, y} ->
      l
      |> Enum.map(&hd/1)
      |> Enum.map(fn {x, _} -> %Vector{x: x, y: y} end)
    end)
    |> List.flatten()
  end
end

defmodule DayThree do
  def sample do
    "467..114..
...*......
..35..633.
......#...
617*......
.....+.58.
..592.....
......755.
...$.*....
.664.598.."
  end

  def input do
    File.read!("inputs/day03")
  end

  def base(use_sample) do
    content = if use_sample, do: sample(), else: input()

    content
    |> String.split("\n", trim: true)
    |> Enum.map(&String.graphemes/1)
    |> Schematic.init()
  end

  def is_symbol(char) do
    !Regex.match?(~r/[0-9.]/, char)
  end

  def vectors_have_symbol(v) do
    v
    |> Enum.any?(&is_symbol/1)
  end

  def part_numbers(schematic) do
    schematic
    |> Schematic.find_numbers()
    |> Enum.map(fn number ->
      y = number[:start].y

      if number[:start].x..number[:end].x
         |> Enum.map(&Schematic.neighbors(schematic, %Vector{x: &1, y: y}))
         |> List.flatten()
         |> Enum.any?(&is_symbol/1) do
        number
      else
        %{}
      end
    end)
    |> Enum.filter(&(&1 != %{}))
    |> Enum.sort(&Vector.less/2)
    |> Enum.dedup()
  end

  def first(use_sample \\ false) do
    schematic = base(use_sample)

    schematic
    |> part_numbers
    |> Enum.map(fn number ->
      y = number[:start].y

      if number[:start].x..number[:end].x
         |> Enum.map(&Schematic.neighbors(schematic, %Vector{x: &1, y: y}))
         |> List.flatten()
         |> Enum.any?(&is_symbol/1) do
        Schematic.get_number(schematic, number[:start].x, number[:end].x, y)
      else
        0
      end
    end)
    |> Enum.sum()
  end

  def second(use_sample \\ false) do
    schematic = base(use_sample)

    schematic
    |> Schematic.find_gears()
    |> Enum.map(fn v ->
      Schematic.neighbor_points(v)
      |> Enum.map(fn neighbor ->
        part_numbers(schematic)
        |> Enum.filter(&Vector.contains(neighbor, &1[:start], &1[:end]))
      end)
    end)
    |> Enum.map(fn line ->
      line
      |> List.flatten()
      |> Enum.sort(&Vector.less/2)
      |> Enum.dedup()
    end)
    |> Enum.filter(&(Enum.count(&1) == 2))
    |> Enum.map(fn l ->
      l
      |> Enum.map(&Schematic.get_number(schematic, &1[:start].x, &1[:end].x, &1[:start].y))
      |> Enum.reduce(1, &*/2)
    end)
    |> Enum.sum()
  end
end
