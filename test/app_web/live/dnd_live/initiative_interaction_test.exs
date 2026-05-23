defmodule AppWeb.DndLive.InitiativeInteractionTest do
  use AppWeb.ConnCase

  import Phoenix.LiveViewTest

  alias App.Dnd

  describe "D&D initiative tracker interactions" do
    setup :register_and_log_in_user

    defp character_fixture(attrs \\ %{}) do
      attrs =
        Map.merge(
          %{
            "name" => "Yhorm The Butcher",
            "race" => "Orc",
            "class" => "Jaeger",
            "level" => 5,
            "hp" => 40,
            "armor_class" => 16,
            "strength" => 18,
            "dexterity" => 12,
            "constitution" => 16,
            "intelligence" => 10,
            "wisdom" => 11,
            "charisma" => 9,
            "notes" => "Front-line fighter."
          },
          attrs
        )

      {:ok, character} = Dnd.create_character(attrs)
      character
    end

    defp combatant_id_from_html(html, name) do
      regex = ~r/<option value="(\d+)">#{Regex.escape(name)}<\/option>/

      case Regex.run(regex, html) do
        [_, id] -> id
        _ -> flunk("Could not find combatant id for #{name} in rendered HTML")
      end
    end

    test "initiative page renders saved characters", %{conn: conn} do
      character = character_fixture()

      {:ok, _live, html} = live(conn, ~p"/dnd/initiative")

      assert html =~ "Initiative Tracker"
      assert html =~ "Add Saved Character"
      assert html =~ character.name
      assert html =~ "Add Custom Combatant"
      assert html =~ "No combatants yet"
    end

    test "adds a saved character to combat", %{conn: conn} do
      character = character_fixture()

      {:ok, live, _html} = live(conn, ~p"/dnd/initiative")

      render_submit(live, "add_saved_character", %{
        "character_id" => Integer.to_string(character.id),
        "initiative" => "18"
      })

      html = render(live)

      assert html =~ "Current Turn"
      assert html =~ character.name
      assert html =~ "Initiative 18"
      assert html =~ "AC 16"
      assert html =~ "HP:"
    end

    test "saved character form handles invalid input without adding combatants", %{conn: conn} do
      {:ok, live, _html} = live(conn, ~p"/dnd/initiative")

      html =
        render_submit(live, "add_saved_character", %{
          "character_id" => "",
          "initiative" => ""
        })

      assert html =~ "Add Saved Character"
      assert html =~ "Choose character"
      assert html =~ "No combatants yet"
    end

    test "adds a custom monster combatant", %{conn: conn} do
      {:ok, live, _html} = live(conn, ~p"/dnd/initiative")

      render_submit(live, "add", %{
        "name" => "Goblin",
        "initiative" => "14",
        "hp" => "12",
        "armor_class" => "13",
        "type" => "monster"
      })

      html = render(live)

      assert html =~ "Goblin"
      assert html =~ "Monster"
      assert html =~ "Initiative 14"
      assert html =~ "AC 13"
      assert html =~ "12"
    end

    test "custom combatant form handles invalid input without adding combatants", %{conn: conn} do
      {:ok, live, _html} = live(conn, ~p"/dnd/initiative")

      html =
        render_submit(live, "add", %{
          "name" => "",
          "initiative" => "",
          "hp" => "",
          "armor_class" => "",
          "type" => "monster"
        })

      assert html =~ "Add Custom Combatant"
      assert html =~ "No combatants yet"
      refute html =~ "Current Turn"
    end

    test "turn order sorts by initiative and next turn advances", %{conn: conn} do
      {:ok, live, _html} = live(conn, ~p"/dnd/initiative")

      render_submit(live, "add", %{
        "name" => "Slow Goblin",
        "initiative" => "5",
        "hp" => "10",
        "armor_class" => "12",
        "type" => "monster"
      })

      render_submit(live, "add", %{
        "name" => "Fast Dragon",
        "initiative" => "20",
        "hp" => "100",
        "armor_class" => "18",
        "type" => "monster"
      })

      html = render(live)

      assert html =~ "Current Turn"
      assert html =~ "Fast Dragon"
      assert html =~ "Up next"

      render_click(live, "next_turn")

      html = render(live)

      assert html =~ "Slow Goblin"
    end

    test "combat action applies damage and healing", %{conn: conn} do
      {:ok, live, _html} = live(conn, ~p"/dnd/initiative")

      render_submit(live, "add", %{
        "name" => "Goblin",
        "initiative" => "12",
        "hp" => "20",
        "armor_class" => "13",
        "type" => "monster"
      })

      html = render(live)
      target_id = combatant_id_from_html(html, "Goblin")

      render_submit(live, "combat_action", %{
        "action" => "damage",
        "target_id" => target_id,
        "value" => "7",
        "condition" => "Blinded"
      })

      html = render(live)

      assert html =~ "13"
      assert html =~ "/ 20"

      render_submit(live, "combat_action", %{
        "action" => "heal",
        "target_id" => target_id,
        "value" => "4",
        "condition" => "Blinded"
      })

      html = render(live)

      assert html =~ "17"
      assert html =~ "/ 20"
    end

    test "combat action can add and remove conditions", %{conn: conn} do
      {:ok, live, _html} = live(conn, ~p"/dnd/initiative")

      render_submit(live, "add", %{
        "name" => "Goblin",
        "initiative" => "12",
        "hp" => "20",
        "armor_class" => "13",
        "type" => "monster"
      })

      html = render(live)
      target_id = combatant_id_from_html(html, "Goblin")

      render_submit(live, "combat_action", %{
        "action" => "condition",
        "target_id" => target_id,
        "value" => "",
        "condition" => "Poisoned"
      })

      html = render(live)

      assert html =~ "Poisoned"

      render_click(live, "remove_condition", %{
        "id" => target_id,
        "condition" => "Poisoned"
      })

      html = render(live)

      refute html =~ "Poisoned ×"
    end

    test "remove deletes a combatant and clear empties combat", %{conn: conn} do
      {:ok, live, _html} = live(conn, ~p"/dnd/initiative")

      render_submit(live, "add", %{
        "name" => "Goblin",
        "initiative" => "12",
        "hp" => "20",
        "armor_class" => "13",
        "type" => "monster"
      })

      html = render(live)
      target_id = combatant_id_from_html(html, "Goblin")

      render_click(live, "remove", %{"id" => target_id})

      html = render(live)

      assert html =~ "No combatants yet"

      render_submit(live, "add", %{
        "name" => "Dragon",
        "initiative" => "19",
        "hp" => "100",
        "armor_class" => "18",
        "type" => "monster"
      })

      assert render(live) =~ "Dragon"

      render_click(live, "clear")

      assert render(live) =~ "No combatants yet"
    end
  end
end
