defmodule App.Characters.Character do
  use Ecto.Schema
  import Ecto.Changeset

  schema "characters" do
    field :name, :string
    field :race, :string
    field :class, :string
    field :level, :integer
    field :hp, :integer
    field :armor_class, :integer
    field :notes, :string
    field :user_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(character, attrs, user_scope) do
    character
    |> cast(attrs, [:name, :race, :class, :level, :hp, :armor_class, :notes])
    |> validate_required([:name, :race, :class, :level, :hp, :armor_class, :notes])
    |> put_change(:user_id, user_scope.user.id)
  end
end
