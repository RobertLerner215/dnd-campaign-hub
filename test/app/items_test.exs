defmodule App.ItemsTest do
  use App.DataCase, async: true

  alias App.Items
  alias App.Items.Item

  @valid_attrs %{"name" => "Test Item", "attributes" => 42}
  @update_attrs %{"name" => "Updated Item", "attributes" => 99}
  @invalid_attrs %{"name" => nil, "attributes" => nil}

  describe "items without scope" do
    test "create_item/2 creates an item" do
      assert {:ok, %Item{} = item} = Items.create_item(nil, @valid_attrs)
      assert item.name == "Test Item"

      # The current Items context normalizes attributes to 0.
      assert item.attributes == 0
    end

    test "list_items/1 returns created items" do
      {:ok, item} = Items.create_item(nil, @valid_attrs)

      items = Items.list_items(nil)
      assert Enum.any?(items, &(&1.id == item.id))
    end

    test "get_item!/2 returns an item by id" do
      {:ok, item} = Items.create_item(nil, @valid_attrs)

      found_item = Items.get_item!(nil, item.id)
      assert found_item.id == item.id
      assert found_item.name == item.name
    end

    test "create_item/2 returns changeset for invalid data" do
      assert {:error, %Ecto.Changeset{}} = Items.create_item(nil, @invalid_attrs)
    end

    test "update_item/3 updates an item name" do
      {:ok, item} = Items.create_item(nil, @valid_attrs)

      assert {:ok, %Item{} = updated_item} = Items.update_item(nil, item, @update_attrs)
      assert updated_item.name == "Updated Item"

      # The current Items context keeps attributes normalized to 0.
      assert updated_item.attributes == 0
    end

    test "update_item/3 returns changeset for invalid data" do
      {:ok, item} = Items.create_item(nil, @valid_attrs)

      assert {:error, %Ecto.Changeset{}} = Items.update_item(nil, item, @invalid_attrs)
    end

    test "delete_item/2 deletes an item" do
      {:ok, item} = Items.create_item(nil, @valid_attrs)

      assert {:ok, %Item{}} = Items.delete_item(nil, item)
      assert_raise Ecto.NoResultsError, fn -> Items.get_item!(nil, item.id) end
    end

    test "change_item/2 returns an item changeset" do
      {:ok, item} = Items.create_item(nil, @valid_attrs)

      assert %Ecto.Changeset{} = Items.change_item(nil, item)
    end
  end
end
