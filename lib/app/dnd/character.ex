defmodule App.Dnd.Character do
  use Ecto.Schema
  import Ecto.Changeset

  schema "characters" do
    field :name, :string
    field :race, :string
    field :class, :string
    field :level, :integer
    field :hp, :integer
    field :armor_class, :integer
    field :strength, :integer
    field :dexterity, :integer
    field :constitution, :integer
    field :intelligence, :integer
    field :wisdom, :integer
    field :charisma, :integer
    field :notes, :string
    field :portrait_path, :string

    has_many :inventory_items, App.Dnd.InventoryItem

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(character, attrs) do
    character
    |> cast(attrs, [
      :name,
      :race,
      :class,
      :level,
      :hp,
      :armor_class,
      :strength,
      :dexterity,
      :constitution,
      :intelligence,
      :wisdom,
      :charisma,
      :notes,
      :portrait_path
    ])
    |> validate_required([:name, :race, :class, :level, :hp, :armor_class])
  end
end
