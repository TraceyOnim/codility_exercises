defmodule PokerDeck do
  @moduledoc """
  Documentation for PokerDeck.
  """
  defstruct [:black, :white]

  @card_values ~w(2 3 4 5 6 7 8 9 T J Q K A) |> Enum.with_index(1)

  def new(black_cards, white_cards) do
    %__MODULE__{black: black_cards, white: white_cards}
  end

  def categorize_player_cards(%{black: black_cards, white: white_cards}) do
    %__MODULE__{
      black: {black_cards, _category(black_cards)},
      white: {white_cards, _category(white_cards)}
    }
  end

  def _category({cards_values, cards_suits} = cards) do
    if has_same_suits?(cards_suits) do
      _flush_or_straight_flush(cards_values)
    else
      cards
    end
  end

  def _category(cards) do
    cards
    |> _card_values_and_suits()
    |> _category()
  end

  def _flush_or_straight_flush(card_values) do
    case has_consecutive_values?(card_values) do
      true -> "straight flush"
      _ -> "flush"
    end
  end

  def has_consecutive_values?(card_values) do
    @card_values
    |> Enum.filter(fn {value, _index} -> value in card_values end)
    |> Enum.map(fn {_value, index} -> index end)
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.all?(fn [x, y] -> y == x + 1 end)
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
