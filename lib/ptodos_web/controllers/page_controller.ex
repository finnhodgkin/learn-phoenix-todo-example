defmodule PtodosWeb.PageController do
  use PtodosWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
