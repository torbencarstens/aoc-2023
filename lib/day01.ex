Code.compiler_options(ignore_module_conflict: true)

defmodule DayOne do
  def sample(part) do
    if part == 1 do
      "1abc2
pqr3stu8vwx
a1b2c3d4e5f
treb7uchet"
    else
      "two1nine
eightwothree
abcone2threexyz
xtwone3four
4nineeightseven2
zoneight234
7pqrstsixteen"
    end
  end

  def input do
    File.read!("inputs/day01")
  end

  def base(use_sample, part) do
    content = if use_sample, do: sample(part), else: input()

    content
    |> String.split("\n", trim: true)
  end

  def convert(s) do
    case s do
      "zero" -> "0"
      "one" -> "1"
      "two" -> "2"
      "three" -> "3"
      "four" -> "4"
      "five" -> "5"
      "six" -> "6"
      "seven" -> "7"
      "eight" -> "8"
      "nine" -> "9"
    end
  end

  def assemble_number([x]), do: assemble_number([x, x])
  def assemble_number([x, y]), do: "#{x}#{y}"
  def assemble_number([x | rest]), do: assemble_number([x, rest |> Enum.take(-1)])

  def parse_number({x, :error}), do: convert(x)
  def parse_number({x, _}), do: x
  def parse_number(x), do: parse_number({x, Integer.parse(x)})

  def first(use_sample \\ false) do
    re = ~r/([0-9])/

    DayOne.base(use_sample, 1)
    |> Enum.map(&Regex.scan(re, &1))
    |> Enum.map(&List.flatten(&1))
    |> Enum.map(&assemble_number/1)
    |> Enum.map(&String.to_integer/1)
    |> Enum.sum()
  end

  def second(use_sample \\ false) do
    re = ~r/(?=(zero|one|two|three|four|five|six|seven|eight|nine|[0-9]))/

    DayOne.base(use_sample, 2)
    |> Enum.map(&Regex.scan(re, &1))
    |> Enum.map(&(&1 |> List.flatten()))
    |> Enum.map(fn line ->
      line
      |> Enum.filter(&(&1 != ""))
      |> Enum.map(&parse_number/1)
    end)
    |> Enum.map(&assemble_number/1)
    |> Enum.map(&String.to_integer/1)
    |> Enum.sum()
  end
end
