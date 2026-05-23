defmodule AppWeb.DndLiveSmokeTest do
  use AppWeb.ConnCase

  import Phoenix.LiveViewTest
  import App.AccountsFixtures

  alias App.Dnd
  alias App.Repo
  alias App.Accounts.User

  setup :register_and_log_in_user

  defp user_from_context(context) do
    cond do
      Map.has_key?(context, :user) -> context.user
      Map.has_key?(context, :scope) -> context.scope.user
      true -> raise "No logged in user found in test context"
    end
  end

  defp user_with_role(role) do
    user_fixture()
    |> User.role_changeset(%{role: role})
    |> Repo.update!()
  end

  defp character_fixture do
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
        "notes" => "A brutal front-line fighter."
      })

    character
  end

  defp inventory_item_fixture(character) do
    attrs = %{
      "name" => "Sword of Doom",
      "owner" => "Party",
      "quantity" => 1,
      "category" => "Weapon",
      "description" => "A dangerous magic sword."
    }

    attrs =
      if character do
        Map.put(attrs, "character_id", character.id)
      else
        attrs
      end

    {:ok, item} = Dnd.create_inventory_item(attrs)
    item
  end

  defp quest_fixture do
    {:ok, quest} =
      Dnd.create_quest(%{
        "title" => "Defeat the Goblin King",
        "giver" => "Village Elder",
        "location" => "Old Mine",
        "reward" => "Ruby Ring",
        "difficulty" => "medium",
        "status" => "available",
        "due_date" => ~D[2026-05-30],
        "description" => "Clear the mine and save the village."
      })

    quest
  end

  describe "D&D dashboard and tools" do
    test "dashboard renders major D&D feature links", %{conn: conn} do
      {:ok, _live, html} = live(conn, ~p"/dnd")

      assert html =~ "D&amp;D Campaign Hub"
      assert html =~ "Dice Roller"
      assert html =~ "Characters"
      assert html =~ "Initiative Tracker"
      assert html =~ "Inventory"
      assert html =~ "Quest Board"
      assert html =~ "Notes"
    end

    test "dice roller page renders", %{conn: conn} do
      {:ok, _live, html} = live(conn, ~p"/dnd/dice")

      assert html =~ "Dice"
      assert html =~ "Roll"
    end

    test "initiative tracker page renders saved characters", %{conn: conn} do
      character = character_fixture()

      {:ok, _live, html} = live(conn, ~p"/dnd/initiative")

      assert html =~ "Initiative"
      assert html =~ character.name
    end
  end

  describe "D&D characters" do
    test "character index renders saved characters", %{conn: conn} do
      character = character_fixture()

      {:ok, _live, html} = live(conn, ~p"/dnd/characters")

      assert html =~ "D&amp;D Characters"
      assert html =~ character.name
      assert html =~ "Open"
      assert html =~ "Edit"
    end

    test "character show renders stats and carried items", %{conn: conn} do
      character = character_fixture()
      item = inventory_item_fixture(character)

      {:ok, _live, html} = live(conn, ~p"/dnd/characters/#{character.id}")

      assert html =~ character.name
      assert html =~ "Ability Scores"
      assert html =~ "Carried Items"
      assert html =~ item.name
    end
  end

  describe "D&D inventory" do
    test "inventory index renders item and assigned character", %{conn: conn} do
      character = character_fixture()
      item = inventory_item_fixture(character)

      {:ok, _live, html} = live(conn, ~p"/dnd/inventory")

      assert html =~ "Party Inventory"
      assert html =~ item.name
      assert html =~ character.name
    end

    test "inventory show renders item details", %{conn: conn} do
      character = character_fixture()
      item = inventory_item_fixture(character)

      {:ok, _live, html} = live(conn, ~p"/dnd/inventory/#{item.id}")

      assert html =~ item.name
      assert html =~ "Assigned To"
      assert html =~ character.name
      assert html =~ "Description / Effect"
    end

    test "inventory form renders character assignment dropdown", %{conn: conn} do
      character = character_fixture()

      {:ok, _live, html} = live(conn, ~p"/dnd/inventory/new")

      assert html =~ "New Inventory Item"
      assert html =~ "Assign to Character"
      assert html =~ character.name
      assert html =~ "Party / Unassigned"
    end
  end

  describe "D&D quests" do
    test "quest board renders saved quest", %{conn: conn} do
      quest = quest_fixture()

      {:ok, _live, html} = live(conn, ~p"/dnd/quests")

      assert html =~ "Quest"
      assert html =~ quest.title
      assert html =~ quest.reward
    end
  end

  describe "D&D notes" do
    test "player sees shared notes and their own notes, but not DM-only notes", context do
      conn = context.conn
      player = user_from_context(context)
      dm = user_with_role("dm")

      {:ok, _shared_note} =
        Dnd.create_note(%{
          "title" => "Shared Clue",
          "body" => "Everyone can see this clue.",
          "visibility" => "shared",
          "user_id" => dm.id
        })

      {:ok, _own_note} =
        Dnd.create_note(%{
          "title" => "My Private Player Note",
          "body" => "Only this player and DM should see this.",
          "visibility" => "private",
          "user_id" => player.id
        })

      {:ok, _dm_only_note} =
        Dnd.create_note(%{
          "title" => "Secret DM Trap",
          "body" => "Players should not see this.",
          "visibility" => "dm_only",
          "user_id" => dm.id
        })

      {:ok, _live, html} = live(conn, ~p"/dnd/notes")

      assert html =~ "Campaign Journal"
      assert html =~ "Shared Clue"
      assert html =~ "My Private Player Note"
      refute html =~ "Secret DM Trap"
    end

    test "note form renders visibility warning for player", %{conn: conn} do
      {:ok, _live, html} = live(conn, ~p"/dnd/notes/new")

      assert html =~ "New Note"
      assert html =~ "Player notes are private"
    end
  end
end
