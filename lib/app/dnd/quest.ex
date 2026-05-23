defmodule App.Dnd.Quest do
  use Ecto.Schema
  import Ecto.Changeset

  schema "quests" do
    field :title, :string
    field :giver, :string
    field :location, :string
    field :reward, :string
    field :difficulty, :string, default: "medium"
    field :status, :string, default: "available"
    field :due_date, :date
    field :description, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(quest, attrs) do
    quest
    |> cast(attrs, [
      :title,
      :giver,
      :location,
      :reward,
      :difficulty,
      :status,
      :due_date,
      :description
    ])
    |> validate_required([:title, :difficulty, :status])
    |> validate_inclusion(:difficulty, ["easy", "medium", "hard", "deadly"])
    |> validate_inclusion(:status, ["available", "in_progress", "completed", "failed"])
  end
end
