defmodule Ptodos.Todos.Todo do
  use Ecto.Schema
  import Ecto.Changeset
  alias Ptodos.Todos.Todo


  schema "todos" do
    field :title, :string
    belongs_to :user, Ptodos.Users.User

    timestamps()
  end

  @doc false
  def changeset(%Todo{} = todo, attrs) do
    todo
    |> cast(attrs, [:title, :user_id])
    |> validate_required([:title, :user_id])
  end
end
