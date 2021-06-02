defmodule PokerDeck do
  @moduledoc """
  Documentation for PokerDeck.
  """
  defstruct [:black, :white]

  def new(black_cards, white_cards) do
    %__MODULE__{black: black_cards, white: white_cards}
  end

  def categorize_player_cards(%{black: black_cards, white: white_cards}) do
    %__MODULE__{
      black: {black_cards, _category(black_cards)},
      white: {white_cards, _category(white_cards)}
    }
  end

  def _category(cards) do
    cards
    |> _card_values_and_suits()
  end

  def _category({cards_values, cards_suits} = cards) do
    if has_same_suits?(cards_suits) do
      _flush_or_straight_flush(cards)()
    else
      cards
    end
  end

  def has_same_suits?([h | _t] = cards_suits) do
    Enum.all?(cards_suits, fn suit -> suit == h end)
  end

  def _card_values_and_suits(cards) do
    Enum.reduce(cards, {[], []}, fn card, {values, suits} ->
      {value, suit} = String.split_at(card, 1)
      {[value | values], [suit | suits]}
    end)
  end
end

# https://stackoverflow.com/questions/66682671/how-to-check-if-an-array-is-in-sequential-and-consecutive-order-in-elixir
