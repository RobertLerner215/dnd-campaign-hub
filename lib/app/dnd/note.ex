defmodule App.Dnd.Note do
  use Ecto.Schema
  import Ecto.Changeset

  schema "notes" do
    field :title, :string
    field :body, :string
    field :visibility, :string, default: "private"
    field :user_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(note, attrs) do
    note
    |> cast(attrs, [:title, :body, :visibility, :user_id])
    |> validate_required([:title, :body, :visibility])
    |> validate_inclusion(:visibility, ["private", "shared", "dm_only"])
  end
end
