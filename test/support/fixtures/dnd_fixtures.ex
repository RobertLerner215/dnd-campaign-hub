defmodule App.DndFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `App.Dnd` context.
  """

  @doc """
  Generate a character.
  """
  def character_fixture(scope, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        armor_class: 42,
        charisma: 42,
        class: "some class",
        constitution: 42,
        dexterity: 42,
        hp: 42,
        intelligence: 42,
        level: 42,
        name: "some name",
        notes: "some notes",
        race: "some race",
        strength: 42,
        wisdom: 42
      })

    {:ok, character} = App.Dnd.create_character(scope, attrs)
    character
  end

  @doc """
  Generate a note.
  """
  def note_fixture(scope, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        body: "some body",
        title: "some title"
      })

    {:ok, note} = App.Dnd.create_note(scope, attrs)
    note
  end

  @doc """
  Generate a inventory_item.
  """
  def inventory_item_fixture(scope, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        category: "some category",
        description: "some description",
        name: "some name",
        owner: "some owner",
        quantity: 42
      })

    {:ok, inventory_item} = App.Dnd.create_inventory_item(scope, attrs)
    inventory_item
  end
end
