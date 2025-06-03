defmodule KiqsideTest do
  use ExUnit.Case
  doctest Kiqside

  test "greets the world" do
    assert Kiqside.hello() == :world
  end
end
