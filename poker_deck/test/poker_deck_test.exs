defmodule PokerDeckTest do
  use ExUnit.Case
  doctest PokerDeck

  test "greets the world" do
    assert PokerDeck.hello() == :world
  end
end
