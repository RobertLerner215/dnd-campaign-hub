defmodule App.ETS do
  use GenServer

  alias App.Games.Minesweeper
  alias App.Planets.Planet

  @name __MODULE__
  @games_table :minesweeper_games

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: @name)
  end

  @impl true
  def init(_) do
    :ets.new(@games_table, [:ordered_set, :named_table, :public])
    :ets.new(:planets, [:set, :named_table, :public])

    load_planets()

    {:ok, []}
  end

  defp load_planets do
    case YamlElixir.read_from_file(Path.join([:code.priv_dir(:app), "planets.yaml"])) do
      {:ok, planets} ->
        rows =
          Enum.map(planets, fn p ->
            planet = Planet.build!(p)
            {planet.id, planet}
          end)

        :ets.insert(:planets, rows)

      _ ->
        IO.puts("Failed to load planets.yaml")
    end
  end

  def create_game do
    game = Minesweeper.build_game()
    :ets.insert(@games_table, {game.id, game})
    game
  end

  def get_game(id) do
    case :ets.lookup(@games_table, id) do
      [{_id, game}] -> game
      _ -> nil
    end
  end

  def set_game(id, attrs) when is_map(attrs) do
    case get_game(id) do
      nil ->
        nil

      game ->
        updated_game = Map.merge(game, attrs)
        :ets.insert(@games_table, {id, updated_game})
        updated_game
    end
  end
end
