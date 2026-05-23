defmodule App.CharactersFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `App.Characters` context.
  """

  @doc """
  Generate a character.
  """
  def character_fixture(scope, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        armor_class: 42,
        class: "some class",
        hp: 42,
        level: 42,
        name: "some name",
        notes: "some notes",
        race: "some race"
      })

    {:ok, character} = App.Characters.create_character(scope, attrs)
    character
  end
end
