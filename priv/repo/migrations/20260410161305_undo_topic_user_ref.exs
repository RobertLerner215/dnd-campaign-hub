defmodule App.Repo.Migrations.UndoTopicUserRef do
  use Ecto.Migration

  def change do
    alter table(:topics) do
      remove :user_id, references(:users, type: :id, on_delete: :delete_all)
    end
  end
end
