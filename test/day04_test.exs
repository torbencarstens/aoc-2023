defmodule DayFourTest do
  use ExUnit.Case
  doctest DayFour

  test "part01 sample" do
    assert DayFour.first(true) == 13
  end

  test "part02 sample" do
    assert DayFour.second(true) == 30
  end
end
