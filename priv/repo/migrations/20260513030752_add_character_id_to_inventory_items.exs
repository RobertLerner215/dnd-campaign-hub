defmodule App.Repo.Migrations.AddCharacterIdToInventoryItems do
  use Ecto.Migration

  def change do
    alter table(:inventory_items) do
      add :character_id, references(:characters, on_delete: :nilify_all)
    end

    create index(:inventory_items, [:character_id])
  end
end
