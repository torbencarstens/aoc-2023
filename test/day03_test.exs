defmodule DayThreeTest do
  use ExUnit.Case
  doctest DayThree

  test "part01 sample" do
    assert DayThree.first(true) == 4361
  end

  test "part02 sample" do
    assert DayThree.second(true) == 467835
  end
end
