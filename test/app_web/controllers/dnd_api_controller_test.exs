defmodule AppWeb.DndApiControllerTest do
  use AppWeb.ConnCase, async: true

  alias App.Dnd

  describe "D&D JSON API" do
    test "GET /api/dnd/characters returns character data", %{conn: conn} do
      {:ok, character} =
        Dnd.create_character(%{
          "name" => "Yhorm The Butcher",
          "race" => "Orc",
          "class" => "Jaeger",
          "level" => 5,
          "hp" => 50,
          "armor_class" => 16,
          "strength" => 18,
          "dexterity" => 12,
          "constitution" => 16,
          "intelligence" => 10,
          "wisdom" => 11,
          "charisma" => 9,
          "notes" => "API test character"
        })

      conn = get(conn, ~p"/api/dnd/characters")

      assert %{"data" => characters} = json_response(conn, 200)

      assert Enum.any?(characters, fn result ->
               result["id"] == character.id and result["name"] == "Yhorm The Butcher"
             end)
    end

    test "GET /api/dnd/inventory returns inventory data", %{conn: conn} do
      {:ok, item} =
        Dnd.create_inventory_item(%{
          "name" => "Health Potion",
          "owner" => "Party",
          "quantity" => 2,
          "category" => "Potion",
          "description" => "Restores HP"
        })

      conn = get(conn, ~p"/api/dnd/inventory")

      assert %{"data" => inventory_items} = json_response(conn, 200)

      assert Enum.any?(inventory_items, fn result ->
               result["id"] == item.id and result["name"] == "Health Potion"
             end)
    end

    test "GET /api/dnd/quests returns quest data", %{conn: conn} do
      {:ok, quest} =
        Dnd.create_quest(%{
          "title" => "Rescue the Blacksmith",
          "giver" => "Mayor",
          "location" => "Bandit Camp",
          "reward" => "Gold",
          "difficulty" => "easy",
          "status" => "available",
          "due_date" => ~D[2026-06-01],
          "description" => "Save the captured blacksmith."
        })

      conn = get(conn, ~p"/api/dnd/quests")

      assert %{"data" => quests} = json_response(conn, 200)

      assert Enum.any?(quests, fn result ->
               result["id"] == quest.id and result["title"] == "Rescue the Blacksmith"
             end)
    end

    test "GET /api/dnd/summary returns campaign counts", %{conn: conn} do
      {:ok, _character} =
        Dnd.create_character(%{
          "name" => "Ezekial",
          "race" => "Human",
          "class" => "Cleric",
          "level" => 3,
          "hp" => 25,
          "armor_class" => 14
        })

      {:ok, _item} =
        Dnd.create_inventory_item(%{
          "name" => "Torch",
          "owner" => "Party",
          "quantity" => 3,
          "category" => "Gear",
          "description" => "Useful in caves"
        })

      {:ok, _quest} =
        Dnd.create_quest(%{
          "title" => "Explore the Ruins",
          "difficulty" => "medium",
          "status" => "in_progress"
        })

      conn = get(conn, ~p"/api/dnd/summary")

      assert %{"data" => summary} = json_response(conn, 200)
      assert summary["characters_count"] >= 1
      assert summary["inventory_items_count"] >= 1
      assert summary["quests_count"] >= 1
      assert summary["in_progress_quests"] >= 1
    end
  end
end
