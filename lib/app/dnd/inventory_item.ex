defmodule App.Dnd.InventoryItem do
  use Ecto.Schema
  import Ecto.Changeset

  schema "inventory_items" do
    field :name, :string
    field :owner, :string
    field :quantity, :integer
    field :category, :string
    field :description, :string

    belongs_to :character, App.Dnd.Character

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(inventory_item, attrs) do
    inventory_item
    |> cast(attrs, [:name, :owner, :quantity, :category, :description, :character_id])
    |> validate_required([:name, :quantity])
    |> validate_number(:quantity, greater_than_or_equal_to: 0)
  end
end
