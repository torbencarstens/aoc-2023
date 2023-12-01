Code.compiler_options(ignore_module_conflict: true)

defmodule DayOne do
  def sample do
    "1abc2
pqr3stu8vwx
a1b2c3d4e5f
treb7uchet"
  end

  def input do
    File.read!("inputs/day01")
  end

  def base do
    DayOne.input()
    |> String.split("\n")
    |> Enum.filter(fn line -> line != "" end)
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

  def first do
    re = ~r/([0-9])/

    DayOne.base()
    |> Enum.map(fn l -> Regex.scan(re, l) end)
    |> Enum.map(fn m -> m |> List.flatten() end)
    |> Enum.map(fn l ->
      l
      |> Enum.filter(fn m -> m != "" end)
      |> Enum.map(fn x ->
        IO.inspect(x)
        {_v, _} = Integer.parse(x)
        x
      end)
    end)
    |> Enum.map(fn l ->
      case l do
        [x] -> "#{x}#{x}"
        [x, y] -> "#{x}#{y}"
        [x | rest] ->
          y = rest |> Enum.take(-1)
          "#{x}#{y}"
      end
    end)
    |> Enum.map(fn s ->
      {v, _} = Integer.parse(s)
      v
    end)
    |> Enum.sum
  end

  def second do
    re = ~r/(?=(zero|one|two|three|four|five|six|seven|eight|nine|[0-9]))/

    DayOne.base()
    |> Enum.map(fn l -> Regex.scan(re, l) end)
    |> Enum.map(fn m -> m |> List.flatten() end)
    |> Enum.map(fn l ->
      l
      |> Enum.filter(fn m -> m != "" end)
      |> Enum.map(fn x ->
        case Integer.parse(x) do
          {_, _} -> x
          :error -> convert(x)
        end
      end)
    end)
    |> Enum.map(fn l ->
      case l do
        [x] -> "#{x}#{x}"
        [x, y] -> "#{x}#{y}"
        [x | rest] ->
          y = rest |> Enum.take(-1)
          "#{x}#{y}"
      end
    end)
    |> Enum.map(fn s ->
      {v, _} = Integer.parse(s)
      v
    end)
    |> Enum.sum
  end
end

IO.inspect(DayOne.first())
