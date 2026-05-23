defmodule AppWeb.DndLive.DiceInteractionTest do
  use AppWeb.ConnCase

  import Phoenix.LiveViewTest

  describe "D&D dice roller interactions" do
    setup :register_and_log_in_user

    test "player can join the dice table", %{conn: conn} do
      {:ok, live, html} = live(conn, ~p"/dnd/dice")

      assert html =~ "D&amp;D Dice Roller"
      assert html =~ "No rolls yet"

      render_submit(live, "join", %{"player_name" => "Yhorm"})

      html = render(live)

      assert html =~ "Yhorm"
      assert html =~ "has joined the table"
    end

    test "normal dice roll appears in the live roll log", %{conn: conn} do
      {:ok, live, _html} = live(conn, ~p"/dnd/dice")

      render_submit(live, "join", %{"player_name" => "Ezekial"})

      render_submit(live, "roll", %{
        "roll" => %{
          "dice_type" => "d20",
          "dice_count" => "1",
          "roll_mode" => "normal",
          "modifier" => "3"
        }
      })

      html = render(live)

      assert html =~ "Ezekial"
      assert html =~ "Rolled"
      assert html =~ "1d20"
      assert html =~ "Modifier"
      assert html =~ "+ 3"
    end

    test "multiple dice roll clamps number of dice and displays label", %{conn: conn} do
      {:ok, live, _html} = live(conn, ~p"/dnd/dice")

      render_submit(live, "join", %{"player_name" => "Kira"})

      render_submit(live, "roll", %{
        "roll" => %{
          "dice_type" => "d6",
          "dice_count" => "3",
          "roll_mode" => "normal",
          "modifier" => "0"
        }
      })

      html = render(live)

      assert html =~ "Kira"
      assert html =~ "3d6"
      assert html =~ "Live Roll Log"
    end

    test "advantage roll displays advantage text", %{conn: conn} do
      {:ok, live, _html} = live(conn, ~p"/dnd/dice")

      render_submit(live, "join", %{"player_name" => "Yhorm"})

      render_submit(live, "roll", %{
        "roll" => %{
          "dice_type" => "d20",
          "dice_count" => "1",
          "roll_mode" => "advantage",
          "modifier" => "2"
        }
      })

      html = render(live)

      assert html =~ "2d20 with advantage"
      assert html =~ "advantage chose"
      assert html =~ "+ 2"
    end

    test "disadvantage roll displays disadvantage text", %{conn: conn} do
      {:ok, live, _html} = live(conn, ~p"/dnd/dice")

      render_submit(live, "join", %{"player_name" => "Ezekial"})

      render_submit(live, "roll", %{
        "roll" => %{
          "dice_type" => "d20",
          "dice_count" => "1",
          "roll_mode" => "disadvantage",
          "modifier" => "-1"
        }
      })

      html = render(live)

      assert html =~ "2d20 with disadvantage"
      assert html =~ "disadvantage chose"
      assert html =~ "- 1"
    end

    test "blank player name rolls as unknown adventurer", %{conn: conn} do
      {:ok, live, _html} = live(conn, ~p"/dnd/dice")

      render_submit(live, "roll", %{
        "roll" => %{
          "dice_type" => "d8",
          "dice_count" => "2",
          "roll_mode" => "normal",
          "modifier" => "0"
        }
      })

      html = render(live)

      assert html =~ "Unknown Adventurer"
      assert html =~ "2d8"
    end
  end
end
