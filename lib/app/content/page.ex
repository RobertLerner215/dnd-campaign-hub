defmodule App.Content.Page do
  use Ecto.Schema
  import Ecto.Changeset

  schema "pages" do
    field :content, :string
    belongs_to :topic, App.Content.Topic
    field :user_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(page, attrs, user_scope) do
    page
    |> cast(attrs, [:content, :topic_id])
    |> validate_required([:content, :topic_id])
    |> foreign_key_constraint(:topic_id)
    |> maybe_put_user(user_scope)
  end

  defp maybe_put_user(changeset, %App.Accounts.Scope{} = scope) do
    put_change(changeset, :user_id, scope.user.id)
  end

  defp maybe_put_user(changeset, nil), do: changeset
end
