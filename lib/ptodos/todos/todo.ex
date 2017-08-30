defmodule Ptodos.Todos.Todo do
  use Ecto.Schema
  import Ecto.Changeset
  alias Ptodos.Todos.Todo


  schema "todos" do
    field :title, :string

    timestamps()
  end

  @doc false
  def changeset(%Todo{} = todo, attrs) do
    todo
    |> cast(attrs, [:title])
    |> validate_required([:title])
  end
end
