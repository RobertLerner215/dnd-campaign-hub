defmodule App.Notifications.Message do
  use Ecto.Schema
  import Ecto.Changeset

  schema "messages" do
    field :email, :string
    field :subject, :string
    field :message, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(message, attrs) do
    message
    |> cast(attrs, [:email, :subject, :message])
    |> validate_required([:email, :message])
    |> validate_format(:email, ~r/@/)
    |> validate_length(:subject, max: 30)
    |> validate_length(:message, min: 5, max: 255)
  end
end
