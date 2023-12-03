Code.compiler_options(ignore_module_conflict: true)

defmodule Vector do
  @enforce_keys [:x, :y]
  defstruct [:x, :y]

  def init(x, y) do
    %Vector{x: x, y: y}
  end

  def v1 +++ v2 do
    import Kernel, only: [+: 2]
    %Vector{x: v1.x + v2.x, y: v1.y + v2.y}
  end

  def has_negative(v) do
    v.x < 0 || v.y < 0
  end

  def contains(vector, start, en) do
    vector.x >= start.x && vector.x <= en.x &&
      vector.y >= start.y && vector.y <= en.y
  end

  def equals(v1, v2) do
    v1.x == v2.x && v1.y == v2.y
  end

  def less(v1, v2) do
    s1 = v1["start"]
    s2 = v2["start"]

    if s1.y < s2.y do
      true
    else
      if s1.y == s2.y do
        s1.x <= s2.x
      else
        false
      end
    end
  end
end
