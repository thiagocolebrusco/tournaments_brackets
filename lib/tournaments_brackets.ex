defmodule TournamentsBrackets do
  use Application

  def start(_type, _args) do
    players =
      IO.gets("Please inform the name of the players separated by comma: ")
      |> String.trim()
      |> String.split(",")
      |> Enum.map(fn name -> String.trim(name) end)

    Enum.with_index(players)
    |> Enum.each(fn {name, index} -> IO.puts("\##{index + 1} #{name}") end)

    players_num = length(players)

    rounds = calc_rounds(players_num)
    number_of_spots = calc_number_of_spots(rounds)
    IO.puts("#{rounds}, #{number_of_spots}")
    spots = calc_spots(players, number_of_spots)
    matches = calc_matches(spots)
    IO.inspect(matches)

    Enum.each(matches, fn match ->
      IO.puts(
        "#{if !is_nil(match.p1.player), do: match.p1.player, else: "Bye"} vs #{if !is_nil(match.p2.player), do: match.p2.player, else: "Bye"}"
      )
    end)

    Supervisor.start_link([], strategy: :one_for_one)
  end

  def calc_rounds(players_num) do
    if players_num < 2 do
      throw("With less than 2 players, there is no tournament")
    end

    validate_number_of_rounds(players_num)
  end

  def calc_number_of_spots(rounds) do
    IO.puts("Rounds: #{rounds}")
    :math.pow(2, rounds)
  end

  def validate_number_of_rounds(players_num, rounds \\ 1) do
    if players_num >= :math.pow(2, rounds) do
      IO.puts("#{players_num} is bigger than #{:math.pow(2, rounds)}")
      validate_number_of_rounds(players_num, rounds + 1)
    else
      rounds
    end
  end

  def calc_spots(players, number_of_spots) do
    spots = Enum.map(1..round(number_of_spots), fn x -> %{spot_n: x, player: nil} end)

    result =
      spots
      |> Enum.shuffle()
      |> Enum.with_index()
      |> Enum.map(fn {x, index} -> %{spot_n: x.spot_n, player: Enum.at(players, index)} end)
      |> Enum.sort_by(& &1.spot_n)

    IO.inspect(result)
  end

  def calc_matches(spots) do
    Enum.map(1..div(length(spots), 2), fn n ->
      %{p1: Enum.at(spots, (n - 1) * 2), p2: Enum.at(spots, (n - 1) * 2 + 1)}
    end)
  end

  def hello do
    :world
  end
end
