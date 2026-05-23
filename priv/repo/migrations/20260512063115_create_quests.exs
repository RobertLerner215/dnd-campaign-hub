defmodule App.Repo.Migrations.CreateQuests do
  use Ecto.Migration

  def change do
    create table(:quests) do
      add :title, :string, null: false
      add :giver, :string
      add :location, :string
      add :reward, :string
      add :difficulty, :string, null: false, default: "medium"
      add :status, :string, null: false, default: "available"
      add :due_date, :date
      add :description, :text

      timestamps(type: :utc_datetime)
    end
  end
end
