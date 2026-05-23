defmodule App.Repo.Migrations.CreateInventoryItems do
  use Ecto.Migration

  def change do
    create table(:inventory_items) do
      add :name, :string
      add :owner, :string
      add :quantity, :integer
      add :category, :string
      add :description, :text
      add :user_id, references(:users, type: :id, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:inventory_items, [:user_id])
  end
end
