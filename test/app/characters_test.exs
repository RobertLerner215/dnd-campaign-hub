defmodule App.CharactersTest do
  use App.DataCase

  alias App.Characters

  describe "characters" do
    alias App.Characters.Character

    import App.AccountsFixtures, only: [user_scope_fixture: 0]
    import App.CharactersFixtures

    @invalid_attrs %{name: nil, level: nil, race: nil, class: nil, hp: nil, armor_class: nil, notes: nil}

    test "list_characters/1 returns all scoped characters" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      character = character_fixture(scope)
      other_character = character_fixture(other_scope)
      assert Characters.list_characters(scope) == [character]
      assert Characters.list_characters(other_scope) == [other_character]
    end

    test "get_character!/2 returns the character with given id" do
      scope = user_scope_fixture()
      character = character_fixture(scope)
      other_scope = user_scope_fixture()
      assert Characters.get_character!(scope, character.id) == character
      assert_raise Ecto.NoResultsError, fn -> Characters.get_character!(other_scope, character.id) end
    end

    test "create_character/2 with valid data creates a character" do
      valid_attrs = %{name: "some name", level: 42, race: "some race", class: "some class", hp: 42, armor_class: 42, notes: "some notes"}
      scope = user_scope_fixture()

      assert {:ok, %Character{} = character} = Characters.create_character(scope, valid_attrs)
      assert character.name == "some name"
      assert character.level == 42
      assert character.race == "some race"
      assert character.class == "some class"
      assert character.hp == 42
      assert character.armor_class == 42
      assert character.notes == "some notes"
      assert character.user_id == scope.user.id
    end

    test "create_character/2 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = Characters.create_character(scope, @invalid_attrs)
    end

    test "update_character/3 with valid data updates the character" do
      scope = user_scope_fixture()
      character = character_fixture(scope)
      update_attrs = %{name: "some updated name", level: 43, race: "some updated race", class: "some updated class", hp: 43, armor_class: 43, notes: "some updated notes"}

      assert {:ok, %Character{} = character} = Characters.update_character(scope, character, update_attrs)
      assert character.name == "some updated name"
      assert character.level == 43
      assert character.race == "some updated race"
      assert character.class == "some updated class"
      assert character.hp == 43
      assert character.armor_class == 43
      assert character.notes == "some updated notes"
    end

    test "update_character/3 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      character = character_fixture(scope)

      assert_raise MatchError, fn ->
        Characters.update_character(other_scope, character, %{})
      end
    end

    test "update_character/3 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      character = character_fixture(scope)
      assert {:error, %Ecto.Changeset{}} = Characters.update_character(scope, character, @invalid_attrs)
      assert character == Characters.get_character!(scope, character.id)
    end

    test "delete_character/2 deletes the character" do
      scope = user_scope_fixture()
      character = character_fixture(scope)
      assert {:ok, %Character{}} = Characters.delete_character(scope, character)
      assert_raise Ecto.NoResultsError, fn -> Characters.get_character!(scope, character.id) end
    end

    test "delete_character/2 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      character = character_fixture(scope)
      assert_raise MatchError, fn -> Characters.delete_character(other_scope, character) end
    end

    test "change_character/2 returns a character changeset" do
      scope = user_scope_fixture()
      character = character_fixture(scope)
      assert %Ecto.Changeset{} = Characters.change_character(scope, character)
    end
  end
end
