defmodule PtodosWeb.TodoController do
  use PtodosWeb, :controller

  alias Ptodos.Todos

  plug :authenticate when action in [:create, :edit, :delete, :update]
  plug :check_owner when action in [:edit, :delete, :update]

  def index(conn, _params) do
    todos = Todos.list_todos()
    changeset = Ptodos.Todos.change_todo(%Ptodos.Todos.Todo{})
    render(conn, "index.html", todos: todos, changeset: changeset)
  end

  def create(conn, %{"todo" => todo_params}) do
    case Todos.create_todo(todo_params, conn.assigns.user) do
      {:ok, _todo} ->
        conn
        |> put_flash(:info, "Todo created successfully.")
        |> redirect(to: todo_path(conn, :index))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def edit(conn, %{"id" => id}) do
    todo = Todos.get_todo!(id)
    changeset = Todos.change_todo(todo)
    render(conn, "edit.html", todo: todo, changeset: changeset)
  end

  def update(conn, %{"id" => id, "todo" => todo_params}) do
    todo = Todos.get_todo!(id)

    case Todos.update_todo(todo, todo_params) do
      {:ok, _todo} ->
        conn
        |> put_flash(:info, "Todo updated successfully.")
        |> redirect(to: todo_path(conn, :index))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", todo: todo, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    todo = Todos.get_todo!(id)
    {:ok, _todo} = Todos.delete_todo(todo)

    conn
    |> put_flash(:info, "Todo deleted successfully.")
    |> redirect(to: todo_path(conn, :index))
  end

  defp check_owner(%{params: %{"id" => id}} = conn, _params) do
    if Todos.get_todo!(id).user_id == conn.assigns.user.id do
      conn
    else
      conn
      |> put_flash(:error, "You don't own that resource.")
      |> redirect(to: todo_path(conn, :index))
      |> halt()
    end
  end

  defp authenticate(conn, _params) do
    if conn.assigns[:user] do
      conn
    else
      conn
      |> put_flash(:error, "Not logged in.")
      |> redirect(to: todo_path(conn, :index))
      |> halt()
    end
  end
end
