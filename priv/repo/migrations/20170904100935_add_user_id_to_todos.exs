defmodule Ptodos.Repo.Migrations.AddUserIdToTodos do
  use Ecto.Migration

  def change do
    alter table(:todos) do
      add :user_id, references(:users)
    end
  end
end
