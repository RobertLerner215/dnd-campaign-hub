defmodule AppWeb.MoreSmokeTest do
  use AppWeb.ConnCase

  import Phoenix.LiveViewTest

  describe "older LiveView pages render without crashing" do
    test "chat page renders", %{conn: conn} do
      {:ok, _live, html} = live(conn, ~p"/chat")

      assert html =~ "Chat"
    end

    test "animations page renders", %{conn: conn} do
      {:ok, _live, html} = live(conn, ~p"/animations")

      assert html =~ "Animation"
    end

    test "gallery page renders", %{conn: conn} do
      {:ok, _live, html} = live(conn, ~p"/gallery")

      assert html =~ "Gallery"
    end

    test "minesweeper base route redirects to a game route", %{conn: conn} do
      assert {:error, {:live_redirect, %{to: path}}} = live(conn, ~p"/minesweeper")
      assert path =~ "/minesweeper/"
    end

    test "rock paper scissors base route redirects to a game route", %{conn: conn} do
      assert {:error, {:live_redirect, %{to: path}}} = live(conn, ~p"/rock-paper-scissors")
      assert path =~ "/rock-paper-scissors/"
      assert path =~ "player=1"
    end

    test "charts page renders", %{conn: conn} do
      {:ok, _live, html} = live(conn, ~p"/charts")

      assert html =~ "Chart"
    end

    test "planets page renders", %{conn: conn} do
      {:ok, _live, html} = live(conn, ~p"/live/planets")

      assert html =~ "Planet"
    end
  end
end
