defmodule DayTwoTest do
  use ExUnit.Case
  doctest DayTwo

  test "part01 sample" do
    assert DayTwo.first(true) == 8
  end

  test "part02 sample" do
    assert DayTwo.second(true) == 2286
  end
end
