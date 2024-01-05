defmodule OceanCatTest do
  use ExUnit.Case
  doctest OceanCat

  test "greets the world" do
    assert OceanCat.hello() == :world
  end
end
