defmodule App.Items do
  @moduledoc """
  The Items context.
  """

  import Ecto.Query, warn: false
  alias App.Repo

  alias App.Items.Item
  alias App.Accounts.Scope

  # -----------------------------
  # SUBSCRIBE
  # -----------------------------
  def subscribe_items(%Scope{} = scope) do
    key = scope.user.id
    Phoenix.PubSub.subscribe(App.PubSub, "user:#{key}:items")
  end

  def subscribe_items(nil), do: :ok

  defp broadcast_item(%Scope{} = scope, message) do
    key = scope.user.id
    Phoenix.PubSub.broadcast(App.PubSub, "user:#{key}:items", message)
  end

  # -----------------------------
  # LIST
  # -----------------------------
  def list_items(%Scope{} = scope) do
    Repo.all(from i in Item, where: i.user_id == ^scope.user.id)
  end

  def list_items(nil) do
    Repo.all(Item)
  end

  # -----------------------------
  # GET
  # -----------------------------
  def get_item!(%Scope{} = scope, id) do
    Repo.get_by!(Item, id: id, user_id: scope.user.id)
  end

  def get_item!(nil, id) do
    Repo.get!(Item, id)
  end

  # -----------------------------
  # CREATE (NO AUTH REQUIRED)
  # -----------------------------
  def create_item(%Scope{} = scope, attrs) do
    attrs =
      attrs
      |> Map.put("attributes", compute_attributes(attrs))
      |> Map.drop(Enum.map(1..8, &"attr#{&1}"))

    with {:ok, item = %Item{}} <-
           %Item{}
           |> Item.changeset(attrs, scope)
           |> Repo.insert() do
      broadcast_item(scope, {:created, item})
      {:ok, item}
    end
  end

  # ✅ FIXED: allow nil scope
  def create_item(nil, attrs) do
    attrs =
      attrs
      |> Map.put("attributes", compute_attributes(attrs))
      |> Map.drop(Enum.map(1..8, &"attr#{&1}"))

    %Item{}
    |> Item.changeset(attrs, nil)
    |> Repo.insert()
  end

  # -----------------------------
  # UPDATE (NO AUTH REQUIRED)
  # -----------------------------
  def update_item(%Scope{} = scope, %Item{} = item, attrs) do
    attrs =
      attrs
      |> Map.put("attributes", compute_attributes(attrs))
      |> Map.drop(Enum.map(1..8, &"attr#{&1}"))

    with {:ok, item = %Item{}} <-
           item
           |> Item.changeset(attrs, scope)
           |> Repo.update() do
      broadcast_item(scope, {:updated, item})
      {:ok, item}
    end
  end

  # ✅ FIXED: allow nil scope
  def update_item(nil, %Item{} = item, attrs) do
    attrs =
      attrs
      |> Map.put("attributes", compute_attributes(attrs))
      |> Map.drop(Enum.map(1..8, &"attr#{&1}"))

    item
    |> Item.changeset(attrs, nil)
    |> Repo.update()
  end

  # -----------------------------
  # DELETE (NO AUTH REQUIRED)
  # -----------------------------
  def delete_item(%Scope{} = scope, %Item{} = item) do
    with {:ok, item = %Item{}} <- Repo.delete(item) do
      broadcast_item(scope, {:deleted, item})
      {:ok, item}
    end
  end

  # ✅ FIXED: allow nil scope
  def delete_item(nil, %Item{} = item) do
    Repo.delete(item)
  end

  # -----------------------------
  # CHANGESET
  # -----------------------------
  def change_item(scope, item, attrs \\ %{})

  def change_item(%Scope{} = scope, %Item{} = item, attrs) do
    Item.changeset(item, attrs, scope)
  end

  def change_item(nil, %Item{} = item, attrs) do
    Item.changeset(item, attrs, nil)
  end

  # -----------------------------
  # ATTRIBUTES HELPER
  # -----------------------------
  defp compute_attributes(attrs) do
    Enum.reduce(1..8, 0, fn i, acc ->
      if Map.get(attrs, "attr#{i}") == "on" do
        acc + Bitwise.bsl(1, i - 1)
      else
        acc
      end
    end)
  end
end
