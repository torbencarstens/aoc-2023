Code.compiler_options(ignore_module_conflict: true)
import Vector

defmodule Schematic do
  #  @enforce_keys [:lines]
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
    |> Enum.map(fn direction ->
      vector +++ direction
    end)
    |> Enum.filter(fn v -> !Vector.has_negative(v) end)
  end

  def neighbors(schematic, vector) do
    neighbor_points(vector)
    |> Enum.map(fn p -> Schematic.at(schematic, p) end)
    |> Enum.filter(fn p -> !is_nil(p) end)
  end

  def is_number(c) do
    Regex.match?(~r/[0-9]/, c)
  end

  def find_numbers_in_line(line, lineno) do
    s = Enum.join(line, "")

    Regex.scan(~r/[0-9]+/, s, return: :index)
    |> Enum.map(&hd/1)
    |> Enum.map(fn m ->
      {si, length} = m
      %{:start => %Vector{x: si, y: lineno}, :end => %Vector{x: si + length - 1, y: lineno}}
    end)
  end

  def find_numbers(schematic) do
    schematic.lines
    |> Enum.with_index(&find_numbers_in_line/2)
    |> Enum.filter(fn l -> l != [] end)
    |> List.flatten()
  end

  def get_number(schematic, start, en, y) do
    s =
      Enum.join(
        start..en
        |> Enum.map(fn x -> Schematic.at(schematic, %Vector{x: x, y: y}) end),
        ""
      )

    {n, _} = Integer.parse(s)
    n
  end

  def find_gears(schematic) do
    schematic.lines
    |> Enum.map(fn line -> Enum.join(line, "") end)
    |> Enum.map(fn line ->
      #      Regex.scan(~r/[0-9]+/, s, return: :index)
      Regex.scan(~r/[*]/, line, return: :index)
    end)
    |> Enum.with_index(fn l, y ->
      if l != [] do
        l
        |> Enum.map(fn m ->
          {si, 1} = m |> hd

          %Vector{x: si, y: y}
        end)
      else
        []
      end
    end)
    |> Enum.filter(fn l -> l != [] end)
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

    lines =
      content
      |> String.split("\n")
      |> Enum.filter(fn line -> line != "" end)
      |> Enum.map(&String.graphemes/1)

    %Schematic{lines: lines}
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
         |> Enum.map(fn x ->
           Schematic.neighbors(schematic, %Vector{x: x, y: y})
         end)
         |> List.flatten()
         |> Enum.any?(&is_symbol/1) do
        number
      else
        %{}
      end
    end)
    |> Enum.filter(fn m -> m != %{} end)
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
         |> Enum.map(fn x ->
           Schematic.neighbors(schematic, %Vector{x: x, y: y})
         end)
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
        |> Enum.filter(fn part_number ->
          Vector.contains(neighbor, part_number[:start], part_number[:end])
        end)
      end)
    end)
    |> Enum.map(fn line ->
      line
      |> List.flatten()
      |> Enum.sort(&Vector.less/2)
      |> Enum.dedup()
    end)
    |> Enum.filter(fn l -> l |> Enum.count() == 2 end)
    |> Enum.map(fn l ->
      l
      |> Enum.map(fn number ->
        Schematic.get_number(schematic, number[:start].x, number[:end].x, number[:start].y)
      end)
      |> Enum.reduce(1, fn x, acc -> acc * x end)
    end)
    |> Enum.sum()
  end
end
