defmodule App.Repo.Migrations.AddPortraitPathToCharacters do
  use Ecto.Migration

  def change do
    alter table(:characters) do
      add :portrait_path, :string
    end
  end
end
