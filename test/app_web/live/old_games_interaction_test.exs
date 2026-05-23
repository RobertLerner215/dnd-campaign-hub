defmodule AppWeb.OldGamesInteractionTest do
  use AppWeb.ConnCase

  import Phoenix.LiveViewTest

  describe "minesweeper LiveView" do
    test "base route redirects to a generated game route", %{conn: conn} do
      assert {:error, {:live_redirect, %{to: path}}} = live(conn, ~p"/minesweeper")
      assert path =~ "/minesweeper/"
    end

    test "game route renders a board and lets user open a cell", %{conn: conn} do
      assert {:error, {:live_redirect, %{to: path}}} = live(conn, ~p"/minesweeper")
      {:ok, live, html} = live(conn, path)

      assert html =~ "Minesweeper"
      assert html =~ "Status"
      assert html =~ "Remaining mines"
      assert html =~ "Game in progress"

      html =
        live
        |> element("button[phx-value-index='0']")
        |> render_click()

      assert html =~ "Status"
      assert html =~ "Remaining mines"
    end

    test "new game button redirects to a new game route", %{conn: conn} do
      assert {:error, {:live_redirect, %{to: path}}} = live(conn, ~p"/minesweeper")
      {:ok, live, _html} = live(conn, path)

      assert {:error, {:live_redirect, %{to: new_path}}} =
               live
               |> element("button", "New Game")
               |> render_click()

      assert new_path =~ "/minesweeper/"
      refute new_path == path
    end
  end

  describe "rock paper scissors LiveView" do
    test "base route redirects to player 1 game route", %{conn: conn} do
      assert {:error, {:live_redirect, %{to: path}}} = live(conn, ~p"/rock-paper-scissors")

      assert path =~ "/rock-paper-scissors/"
      assert path =~ "player=1"
    end

    test "player pages render player links and controls", %{conn: conn} do
      game_id = Ecto.UUID.generate()

      {:ok, player1_live, html1} = live(conn, ~p"/rock-paper-scissors/#{game_id}?player=1")
      {:ok, _player2_live, html2} = live(conn, ~p"/rock-paper-scissors/#{game_id}?player=2")

      assert html1 =~ "Rock Paper Scissors"
      assert html1 =~ "Player 1 Link"
      assert html1 =~ "Player 2 Link"
      assert html1 =~ "You are Player 1"
      assert html1 =~ "Waiting for moves"
      assert html1 =~ "Rock"
      assert html1 =~ "Paper"
      assert html1 =~ "Scissors"

      assert html2 =~ "You are Player 2"

      html =
        player1_live
        |> element("button", "🪨 Rock")
        |> render_click()

      assert html =~ "Player1 = rock"
    end

    test "player 1 can win a round", %{conn: conn} do
      game_id = Ecto.UUID.generate()

      {:ok, player1_live, _html} = live(conn, ~p"/rock-paper-scissors/#{game_id}?player=1")
      {:ok, player2_live, _html} = live(conn, ~p"/rock-paper-scissors/#{game_id}?player=2")

      player1_live
      |> element("button", "🪨 Rock")
      |> render_click()

      html =
        player2_live
        |> element("button", "✂️ Scissors")
        |> render_click()

      assert html =~ "Player 1 wins"
      assert html =~ "rock beats scissors"
    end

    test "player 2 can win a round", %{conn: conn} do
      game_id = Ecto.UUID.generate()

      {:ok, player1_live, _html} = live(conn, ~p"/rock-paper-scissors/#{game_id}?player=1")
      {:ok, player2_live, _html} = live(conn, ~p"/rock-paper-scissors/#{game_id}?player=2")

      player1_live
      |> element("button", "🪨 Rock")
      |> render_click()

      html =
        player2_live
        |> element("button", "📄 Paper")
        |> render_click()

      assert html =~ "Player 2 wins"
      assert html =~ "paper beats rock"
    end

    test "players can tie a round", %{conn: conn} do
      game_id = Ecto.UUID.generate()

      {:ok, player1_live, _html} = live(conn, ~p"/rock-paper-scissors/#{game_id}?player=1")
      {:ok, player2_live, _html} = live(conn, ~p"/rock-paper-scissors/#{game_id}?player=2")

      player1_live
      |> element("button", "🪨 Rock")
      |> render_click()

      html =
        player2_live
        |> element("button", "🪨 Rock")
        |> render_click()

      assert html =~ "Tie"
      assert html =~ "rock = rock"
    end
  end
end
