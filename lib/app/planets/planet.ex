defmodule App.Planets.Planet do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false

  embedded_schema do
    field :id, :integer
    field :name, :string
    field :moons, :integer
    field :distance, :float
    field :orbital_period, :integer
  end

  def build!(params) do
    %__MODULE__{}
    |> cast(params, [:id, :name, :moons, :distance, :orbital_period])
    |> validate_required([:id, :name, :moons, :distance, :orbital_period])
    |> apply_action!(:insert)
  end
end
