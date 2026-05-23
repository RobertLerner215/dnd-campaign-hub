defmodule AppWeb.FinalProjectExtraSmokeTest do
  use AppWeb.ConnCase

  import Phoenix.LiveViewTest

  alias App.Dnd
  alias App.Repo
  alias App.Accounts.User

  setup :register_and_log_in_user

  defp make_dm(user) do
    user
    |> User.role_changeset(%{role: "dm"})
    |> Repo.update!()
  end

  defp user_from_context(context) do
    cond do
      Map.has_key?(context, :user) -> context.user
      Map.has_key?(context, :scope) -> context.scope.user
      true -> raise "No logged in user found"
    end
  end

  defp character_fixture do
    {:ok, character} =
      Dnd.create_character(%{
        "name" => "Ezekial",
        "race" => "Human",
        "class" => "Cleric",
        "level" => 4,
        "hp" => 32,
        "armor_class" => 15,
        "strength" => 10,
        "dexterity" => 12,
        "constitution" => 14,
        "intelligence" => 11,
        "wisdom" => 18,
        "charisma" => 13,
        "notes" => "A support character."
      })

    character
  end

  defp quest_fixture do
    {:ok, quest} =
      Dnd.create_quest(%{
        "title" => "Save the Lost Caravan",
        "giver" => "Merchant Guild",
        "location" => "Northern Road",
        "reward" => "Bag of Gold",
        "difficulty" => "hard",
        "status" => "in_progress",
        "due_date" => ~D[2026-06-10],
        "description" => "Find the missing caravan before nightfall."
      })

    quest
  end

  defp note_fixture(user, visibility, title) do
    {:ok, note} =
      Dnd.create_note(%{
        "title" => title,
        "body" => "Test note body for #{title}",
        "visibility" => visibility,
        "user_id" => user.id
      })

    note
  end

  describe "extra D&D LiveView coverage" do
    test "character new form renders full character form", %{conn: conn} do
      {:ok, _live, html} = live(conn, ~p"/dnd/characters/new")

      assert html =~ "New Character"
      assert html =~ "Name"
      assert html =~ "Race"
      assert html =~ "Class"
      assert html =~ "Strength"
      assert html =~ "Charisma"
      assert html =~ "Portrait"
      assert html =~ "Save Character"
    end

    test "character edit form renders existing character", %{conn: conn} do
      character = character_fixture()

      {:ok, _live, html} = live(conn, ~p"/dnd/characters/#{character.id}/edit")

      assert html =~ "Edit Character"
      assert html =~ character.name
      assert html =~ "Save Character"
    end

    test "note show page renders note for owner", context do
      user = user_from_context(context)
      note = note_fixture(user, "private", "Player Secret")

      {:ok, _live, html} = live(context.conn, ~p"/dnd/notes/#{note.id}")

      assert html =~ "Player Secret"
      assert html =~ "Test note body"
    end

    test "note edit form renders note fields", context do
      user = user_from_context(context)
      note = note_fixture(user, "private", "Editable Player Note")

      {:ok, _live, html} = live(context.conn, ~p"/dnd/notes/#{note.id}/edit")

      assert html =~ "Edit Note"
      assert html =~ "Editable Player Note"
      assert html =~ "Body"
      assert html =~ "Save Note"
    end

    test "DM note page can see DM-only note", context do
      dm = make_dm(user_from_context(context))
      note_fixture(dm, "dm_only", "Hidden Dragon Trap")

      {:ok, _live, html} = live(context.conn, ~p"/dnd/notes")

      assert html =~ "Campaign Journal"
      assert html =~ "Hidden Dragon Trap"
    end

    test "quest board can update quest status with buttons present", %{conn: conn} do
      quest = quest_fixture()

      {:ok, _live, html} = live(conn, ~p"/dnd/quests")

      assert html =~ quest.title
      assert html =~ "In Progress"
      assert html =~ "Completed"
      assert html =~ "Failed"
    end

    test "quest board renders new quest form area", %{conn: conn} do
      {:ok, _live, html} = live(conn, ~p"/dnd/quests")

      assert html =~ "Quest"
      assert html =~ "Difficulty"
      assert html =~ "Reward"
      assert html =~ "Due"
    end

    test "dice page includes advanced dice controls", %{conn: conn} do
      {:ok, _live, html} = live(conn, ~p"/dnd/dice")

      assert html =~ "Advantage"
      assert html =~ "Disadvantage"
      assert html =~ "Modifier"
      assert html =~ "Roll"
    end

    test "initiative page includes combat controls", %{conn: conn} do
      character = character_fixture()

      {:ok, _live, html} = live(conn, ~p"/dnd/initiative")

      assert html =~ "Initiative"
      assert html =~ character.name
      assert html =~ "HP"
      assert html =~ "AC"
    end
  end
end
