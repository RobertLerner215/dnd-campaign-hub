defmodule AppWeb.ItemLiveTest do
  use AppWeb.ConnCase

  import Phoenix.LiveViewTest

  alias App.Items

  setup :register_and_log_in_user

  defp scope_from_context(context) do
    cond do
      Map.has_key?(context, :scope) -> context.scope
      Map.has_key?(context, :current_scope) -> context.current_scope
      true -> nil
    end
  end

  defp item_fixture(scope, attrs \\ %{}) do
    attrs =
      Map.merge(
        %{
          "name" => "Test Item",
          "attributes" => 0
        },
        attrs
      )

    {:ok, item} = Items.create_item(scope, attrs)
    item
  end

  describe "item LiveViews" do
    test "index renders items", context do
      scope = scope_from_context(context)
      item = item_fixture(scope)

      {:ok, _index_live, html} = live(context.conn, ~p"/items")

      assert html =~ "Listing Items"
      assert html =~ item.name
      assert html =~ "New Item"
      assert html =~ "Show"
      assert html =~ "Edit"
      assert html =~ "Delete"
    end

    test "show renders item details", context do
      scope = scope_from_context(context)
      item = item_fixture(scope, %{"name" => "Magic Torch"})

      {:ok, _show_live, html} = live(context.conn, ~p"/items/#{item.id}")

      assert html =~ "Item #{item.id}"
      assert html =~ "Magic Torch"
      assert html =~ "Attributes"
      assert html =~ "Edit item"
    end

    test "new form renders item form", %{conn: conn} do
      {:ok, _form_live, html} = live(conn, ~p"/items/new")

      assert html =~ "New Item"
      assert html =~ "Use this form to manage item records."
      assert html =~ "Name"
      assert html =~ "Attr 1"
      assert html =~ "Attr 8"
      assert html =~ "Save Item"
      assert html =~ "Cancel"
    end

    test "edit form renders existing item", context do
      scope = scope_from_context(context)
      item = item_fixture(scope, %{"name" => "Old Sword"})

      {:ok, _form_live, html} = live(context.conn, ~p"/items/#{item.id}/edit")

      assert html =~ "Edit Item"
      assert html =~ "Old Sword"
      assert html =~ "Save Item"
      assert html =~ "Cancel"
    end

    test "new form validates invalid data", %{conn: conn} do
      {:ok, form_live, _html} = live(conn, ~p"/items/new")

      html =
        form_live
        |> form("#item-form", item: %{"name" => ""})
        |> render_change()

      assert html =~ "can&#39;t be blank"
    end

    test "edit form validates invalid data", context do
      scope = scope_from_context(context)
      item = item_fixture(scope, %{"name" => "Potion"})

      {:ok, form_live, _html} = live(context.conn, ~p"/items/#{item.id}/edit")

      html =
        form_live
        |> form("#item-form", item: %{"name" => ""})
        |> render_change()

      assert html =~ "can&#39;t be blank"
    end

    test "delete removes item from index", context do
      scope = scope_from_context(context)
      _item = item_fixture(scope, %{"name" => "Delete Me"})

      {:ok, index_live, html} = live(context.conn, ~p"/items")

      assert html =~ "Delete Me"

      index_live
      |> element("a", "Delete")
      |> render_click()

      refute render(index_live) =~ "Delete Me"
    end
  end
end
