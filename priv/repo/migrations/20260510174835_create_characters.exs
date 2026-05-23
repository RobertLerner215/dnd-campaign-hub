defmodule App.Repo.Migrations.CreateCharacters do
  use Ecto.Migration

  def change do
    create table(:characters) do
      add :name, :string
      add :race, :string
      add :class, :string
      add :level, :integer
      add :hp, :integer
      add :armor_class, :integer
      add :strength, :integer
      add :dexterity, :integer
      add :constitution, :integer
      add :intelligence, :integer
      add :wisdom, :integer
      add :charisma, :integer
      add :notes, :text
      add :user_id, references(:users, type: :id, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:characters, [:user_id])
  end
end
