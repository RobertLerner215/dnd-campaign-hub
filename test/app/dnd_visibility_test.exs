defmodule App.DndVisibilityTest do
  use App.DataCase, async: true

  alias App.Dnd
  alias App.Repo
  alias App.Accounts.User

  import App.AccountsFixtures

  defp user_with_role(role) do
    user_fixture()
    |> User.role_changeset(%{role: role})
    |> Repo.update!()
  end

  describe "role-based note visibility" do
    test "DM sees private, shared, and DM-only notes" do
      dm = user_with_role("dm")
      player = user_with_role("player")

      {:ok, private_note} =
        Dnd.create_note(%{
          "title" => "DM Private",
          "body" => "secret private note",
          "visibility" => "private",
          "user_id" => dm.id
        })

      {:ok, shared_note} =
        Dnd.create_note(%{
          "title" => "Shared Clue",
          "body" => "players can see this",
          "visibility" => "shared",
          "user_id" => dm.id
        })

      {:ok, dm_only_note} =
        Dnd.create_note(%{
          "title" => "DM Only",
          "body" => "only dm can see this",
          "visibility" => "dm_only",
          "user_id" => dm.id
        })

      {:ok, player_note} =
        Dnd.create_note(%{
          "title" => "Player Private",
          "body" => "player private note",
          "visibility" => "private",
          "user_id" => player.id
        })

      note_ids =
        dm
        |> Dnd.list_notes_for_user()
        |> Enum.map(& &1.id)

      assert private_note.id in note_ids
      assert shared_note.id in note_ids
      assert dm_only_note.id in note_ids
      assert player_note.id in note_ids
    end

    test "player sees shared notes and their own private notes only" do
      dm = user_with_role("dm")
      player = user_with_role("player")
      other_player = user_with_role("player")

      {:ok, _dm_private_note} =
        Dnd.create_note(%{
          "title" => "DM Private",
          "body" => "hidden from players",
          "visibility" => "private",
          "user_id" => dm.id
        })

      {:ok, shared_note} =
        Dnd.create_note(%{
          "title" => "Shared Note",
          "body" => "visible to players",
          "visibility" => "shared",
          "user_id" => dm.id
        })

      {:ok, _dm_only_note} =
        Dnd.create_note(%{
          "title" => "DM Only Note",
          "body" => "hidden from players",
          "visibility" => "dm_only",
          "user_id" => dm.id
        })

      {:ok, own_note} =
        Dnd.create_note(%{
          "title" => "My Player Note",
          "body" => "my private note",
          "visibility" => "private",
          "user_id" => player.id
        })

      {:ok, _other_player_note} =
        Dnd.create_note(%{
          "title" => "Other Player Note",
          "body" => "not mine",
          "visibility" => "private",
          "user_id" => other_player.id
        })

      notes = Dnd.list_notes_for_user(player)
      note_titles = Enum.map(notes, & &1.title)

      assert "Shared Note" in note_titles
      assert "My Player Note" in note_titles
      refute "DM Private" in note_titles
      refute "DM Only Note" in note_titles
      refute "Other Player Note" in note_titles

      note_ids = Enum.map(notes, & &1.id)
      assert shared_note.id in note_ids
      assert own_note.id in note_ids
    end
  end

  describe "character inventory association" do
    test "character can have carried inventory items" do
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
          "notes" => "Test character"
        })

      {:ok, item} =
        Dnd.create_inventory_item(%{
          "name" => "Sword of Doom",
          "owner" => "Yhorm",
          "quantity" => 1,
          "category" => "Weapon",
          "description" => "A test weapon",
          "character_id" => character.id
        })

      loaded_character = Dnd.get_character!(character.id)

      assert Enum.any?(loaded_character.inventory_items, fn carried_item ->
               carried_item.id == item.id
             end)
    end
  end

  describe "quest reward integration" do
    test "quest reward can be added to inventory" do
      {:ok, quest} =
        Dnd.create_quest(%{
          "title" => "Defeat the Goblin King",
          "giver" => "Village Elder",
          "location" => "Old Mine",
          "reward" => "Ruby Ring",
          "difficulty" => "medium",
          "status" => "available",
          "due_date" => ~D[2026-05-30],
          "description" => "Clear the old mine."
        })

      assert {:ok, item} = Dnd.add_quest_reward_to_inventory(quest)

      assert item.name == "Ruby Ring"
      assert item.owner == "Party"
      assert item.category == "Quest Reward"
      assert item.description =~ "Defeat the Goblin King"
    end

    test "quest status can be updated" do
      {:ok, quest} =
        Dnd.create_quest(%{
          "title" => "Find the Relic",
          "difficulty" => "hard",
          "status" => "available"
        })

      assert {:ok, updated_quest} = Dnd.update_quest_status(quest, "completed")
      assert updated_quest.status == "completed"
    end
  end
end
