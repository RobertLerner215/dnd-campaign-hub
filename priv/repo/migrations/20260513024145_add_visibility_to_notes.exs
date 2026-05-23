defmodule App.Repo.Migrations.AddVisibilityToNotes do
  use Ecto.Migration

  def change do
    alter table(:notes) do
      add :visibility, :string, null: false, default: "private"
    end
  end
end
