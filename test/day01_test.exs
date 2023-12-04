defmodule DayOneTest do
  use ExUnit.Case
  doctest DayOne

  test "part01 sample" do
    assert DayOne.first(true) == 142
  end

  test "part02 sample" do
    assert DayOne.second(true) == 281
  end
end
