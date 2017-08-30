defmodule Ptodos.Repo.Migrations.CreateTodos do
  use Ecto.Migration

  def change do
    create table(:todos) do
      add :title, :string

      timestamps()
    end

  end
end
