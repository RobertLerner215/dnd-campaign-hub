defmodule App.Games.MinesweeperTest do
  use App.DataCase, async: true

  alias App.Games.Minesweeper

  defp custom_game(mine_indexes, open_indexes \\ []) do
    mine_map =
      for index <- 0..80 do
        index in mine_indexes
      end

    open_map =
      for index <- 0..80 do
        index in open_indexes
      end

    %Minesweeper{
      id: "test-game",
      mine_map: mine_map,
      open_map: open_map,
      last_opened: nil,
      finished: false,
      won: false
    }
  end

  describe "build_game/0" do
    test "builds a new game with correct defaults" do
      game = Minesweeper.build_game()

      assert is_binary(game.id)
      assert length(game.mine_map) == 81
      assert length(game.open_map) == 81
      assert Enum.count(game.mine_map, & &1) == 10
      assert Enum.all?(game.open_map, &(&1 == false))
      assert game.last_opened == nil
      refute game.finished
      refute game.won
    end
  end

  describe "open_field/2" do
    test "opens a safe field and keeps game going" do
      game = custom_game([8])
      updated_game = Minesweeper.open_field(game, 0)

      assert Enum.at(updated_game.open_map, 0)
      assert updated_game.last_opened == 0
      refute updated_game.finished
      refute updated_game.won
    end

    test "opening a mine ends the game as a loss" do
      game = custom_game([0])
      updated_game = Minesweeper.open_field(game, 0)

      assert Enum.at(updated_game.open_map, 0)
      assert updated_game.last_opened == 0
      assert updated_game.finished
      refute updated_game.won
    end

    test "opening the final safe field wins the game" do
      mine_indexes = [80]
      open_indexes = Enum.to_list(0..79) -- [25]

      game = custom_game(mine_indexes, open_indexes)
      updated_game = Minesweeper.open_field(game, 25)

      assert Enum.at(updated_game.open_map, 25)
      assert updated_game.last_opened == 25
      assert updated_game.finished
      assert updated_game.won
    end

    test "opening an already opened field does not change the game" do
      game = custom_game([80], [0])
      updated_game = Minesweeper.open_field(game, 0)

      assert updated_game == game
    end

    test "opening a field after game is finished does not change the game" do
      game =
        custom_game([0])
        |> Map.put(:finished, true)
        |> Map.put(:won, false)

      updated_game = Minesweeper.open_field(game, 5)

      assert updated_game == game
    end
  end

  describe "adjacent_count/2" do
    test "counts adjacent mines for a corner cell" do
      game = custom_game([1, 9, 10])

      assert Minesweeper.adjacent_count(game, 0) == 3
    end

    test "counts adjacent mines for a center cell" do
      game = custom_game([30, 31, 32, 39, 41, 48, 49, 50])

      assert Minesweeper.adjacent_count(game, 40) == 8
    end

    test "does not count the selected cell itself" do
      game = custom_game([40])

      assert Minesweeper.adjacent_count(game, 40) == 0
    end
  end

  describe "remaining_mines/1" do
    test "counts unopened mines" do
      game = custom_game([0, 1, 2], [0])

      assert Minesweeper.remaining_mines(game) == 2
    end
  end
end
