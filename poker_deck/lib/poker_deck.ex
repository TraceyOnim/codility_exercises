defmodule PokerDeck do
  @moduledoc """
  Documentation for PokerDeck.
  """
  defstruct [:black, :white]

  @card_values ~w(2 3 4 5 6 7 8 9 T J Q K A) |> Enum.with_index(1)

  def new(%{} = cards) do
    %__MODULE__{}
    |> Map.merge(cards)
  end

  def categorize_player_cards(%{black: black_cards, white: white_cards}) do
    %__MODULE__{
      black: {black_cards, _category(black_cards), :black},
      white: {white_cards, _category(white_cards), :white}
    }
  end

  # converter
  # wip in progress
  def display_results(cards) do
    cards
    |> new()
    |> categorize_player_cards()
    |> rank_cards()
    |> higher_rank()
    |> results()
  end

  def _category([_h | _t] = cards) do
    cards
    |> _card_values_and_suits()
    |> _category()
  end

  def _category({cards_values, cards_suits}) do
    if has_same_suits?(cards_suits) do
      _flush_or_straight_flush(cards_values)
    else
      _category_name(cards_values)
    end
  end

  def _category_name([_h | _t] = card_values) do
    {values, frequencies} =
      card_values
      |> Enum.frequencies()
      |> Enum.unzip()

    frequencies = Enum.sort(frequencies, :desc)
    _category_name({values, frequencies})
  end

  def _category_name({_values, [2 | _] = frequencies}) do
    case Enum.count(frequencies, fn frequency -> frequency == 2 end) do
      2 -> :two_pair
      _ -> :pair
    end
  end

  def _category_name({_values, [3, 2]}) do
    :full_house
  end

  def _category_name({_values, [3 | _]}) do
    :three_of_a_kind
  end

  def _category_name({_values, [4, 1]}) do
    :four_of_a_kind
  end

  def _category_name(_) do
    :high_card
  end

  def _flush_or_straight_flush(card_values) do
    case has_consecutive_values?(card_values) do
      true -> :straight_flush
      _ -> :flush
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

  def rank_cards(%{black: black_cards, white: white_cards}) do
    %__MODULE__{
      black: black_cards |> Tuple.append(rank_cards(black_cards)),
      white: white_cards |> Tuple.append(rank_cards(white_cards))
    }
  end

  def rank_cards({cards, :high_card, _player}) do
    {card_values, _suits} = PokerDeck._card_values_and_suits(cards)

    @card_values
    |> Enum.filter(fn {value, _index} -> value in card_values end)
    |> Enum.max_by(fn {_value, index} -> index end)
  end

  def rank_cards({cards, _category, _player}) do
    cards
  end

  def higher_rank(%{black: black_cards, white: white_cards}) do
    {_cards, _category, _player_b, {_, index_b}} = black_cards

    {_cards, _category, _player_w, {_, index_w}} = white_cards

    Enum.find([black_cards, white_cards], fn {_cards, _category, _player, {_value, index}} ->
      index == max(index_b, index_w)
    end)
  end

  def results({_cards, category, player, {value, _}}) do
    "#{player} wins-#{to_string(category)}: #{card_name(value)}"
  end

  def card_name("A"), do: "Ace"
  def card_name("K"), do: "King"
  def card_name("Q"), do: "Queen"
  def card_name("J"), do: "Jack"
  def card_name("T"), do: "10"
  def card_name(value), do: value
end
