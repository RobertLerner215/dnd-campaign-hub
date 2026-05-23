defmodule App.Items.Item do
  use Ecto.Schema
  import Ecto.Changeset

  schema "items" do
    field :name, :string
    field :attributes, :integer
    field :user_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(item, attrs, user_scope) do
    item
    |> cast(attrs, [:name, :attributes])
    |> validate_required([:name, :attributes])
    |> maybe_put_user(user_scope)
  end

  defp maybe_put_user(changeset, %App.Accounts.Scope{} = scope) do
    put_change(changeset, :user_id, scope.user.id)
  end

  defp maybe_put_user(changeset, nil), do: changeset
end
