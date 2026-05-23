defmodule App.ItemsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `App.Items` context.
  """

  @doc """
  Generate a item.
  """
  def item_fixture(scope, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        attributes: 42,
        name: "some name"
      })

    {:ok, item} = App.Items.create_item(scope, attrs)
    item
  end
end
