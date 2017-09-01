defmodule PtodosWeb.AuthController do
  use PtodosWeb, :controller
  plug Ueberauth

  def callback(%{assigns: %{ueberauth_auth: %{info: %{email: email, name: name}}}} = conn, _params) do
    redirect(conn, to: todo_path(conn, :index))
  end

  def signout(conn, _params) do
    conn
  end
end
