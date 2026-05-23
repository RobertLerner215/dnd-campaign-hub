defmodule App.Games.Minesweeper do
  use Ecto.Schema

  @grid_size 9
  @cell_count 81
  @mine_count 10

  @primary_key false
  embedded_schema do
    field :id, :string
    field :mine_map, {:array, :boolean}, default: []
    field :open_map, {:array, :boolean}, default: []
    field :last_opened, :integer
    field :finished, :boolean, default: false
    field :won, :boolean, default: false
  end

  @doc """
  Builds a brand new minesweeper game.
  """
  def build_game do
    %__MODULE__{
      id: Ecto.UUID.generate(),
      mine_map: create_random_mines(),
      open_map: List.duplicate(false, @cell_count),
      last_opened: nil,
      finished: false,
      won: false
    }
  end

  @doc """
  Opens one field on the board.
  If it is a mine, the game ends.
  If all safe cells are opened, the game is won.
  """
  def open_field(%__MODULE__{finished: true} = game, _index), do: game

  def open_field(%__MODULE__{} = game, index)
      when is_integer(index) and index >= 0 and index < @cell_count do
    if Enum.at(game.open_map, index) do
      game
    else
      open_map = List.replace_at(game.open_map, index, true)
      clicked_mine = Enum.at(game.mine_map, index)

      cond do
        clicked_mine ->
          %{
            game
            | open_map: open_map,
              last_opened: index,
              finished: true,
              won: false
          }

        won?(game.mine_map, open_map) ->
          %{
            game
            | open_map: open_map,
              last_opened: index,
              finished: true,
              won: true
          }

        true ->
          %{
            game
            | open_map: open_map,
              last_opened: index,
              finished: false,
              won: false
          }
      end
    end
  end

  @doc """
  Counts how many mines are adjacent to a given index.
  """
  def adjacent_count(%__MODULE__{} = game, index)
      when is_integer(index) and index >= 0 and index < @cell_count do
    x = rem(index, @grid_size)
    y = div(index, @grid_size)

    for dx <- -1..1,
        dy <- -1..1,
        not (dx == 0 and dy == 0),
        valid_coord?(x + dx, y + dy),
        reduce: 0 do
      acc ->
        neighbor_index = get_index(x + dx, y + dy)

        if Enum.at(game.mine_map, neighbor_index) do
          acc + 1
        else
          acc
        end
    end
  end

  @doc """
  Returns the number of mines that are still hidden.
  """
  def remaining_mines(%__MODULE__{} = game) do
    Enum.zip(game.mine_map, game.open_map)
    |> Enum.count(fn {is_mine, is_open} -> is_mine and not is_open end)
  end

  defp won?(mine_map, open_map) do
    Enum.with_index(mine_map)
    |> Enum.all?(fn {is_mine, index} ->
      is_mine or Enum.at(open_map, index)
    end)
  end

  # Returns a list of 81 booleans with 10 mines at random positions.
  defp create_random_mines do
    List.duplicate(true, @mine_count)
    |> Kernel.++(List.duplicate(false, @cell_count - @mine_count))
    |> Enum.shuffle()
  end

  defp valid_coord?(x, y) do
    x >= 0 and x < @grid_size and y >= 0 and y < @grid_size
  end

  defp get_index(x, y), do: y * @grid_size + x
end
