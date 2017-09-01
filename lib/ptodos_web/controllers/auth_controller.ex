defmodule PtodosWeb.AuthController do
  use PtodosWeb, :controller
  plug Ueberauth

  alias Ptodos.Users

  def callback(%{assigns: %{ueberauth_auth: %{info: %{email: email, name: name}}}} = conn, _params) do
    case insert_or_sign_user(%{email: email, name: name}) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "Welcome back!")
        |> redirect(to: todo_path(conn, :index))
      {:error, _reason} ->
        conn
        |> put_flash(:error, "Error signing in")
        |> redirect(to: todo_path(conn, :index))
    end
  end

  def signout(conn, _params) do
    conn
    |> put_flash(:info, "Signed out")
    |> configure_session(drop: true)
    |> redirect(to: todo_path(conn, :index))
  end

  defp insert_or_sign_user(user) do
    case Users.get_by_email(user.email) do
      nil ->
        Users.create_user(user)
      user ->
        {:ok, user}
    end
  end
end
