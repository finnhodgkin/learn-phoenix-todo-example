defmodule PtodosWeb.Router do
  use PtodosWeb, :router

  require Ueberauth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug PtodosWeb.Plugs.SetUser
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", PtodosWeb do
    pipe_through :browser # Use the default browser stack

    resources "/", TodoController
  end

  scope "/auth", PtodosWeb do
    pipe_through :browser

    get "/signout", AuthController, :signout
    get "/:provider", AuthController, :request
    get "/:provider/callback", AuthController, :callback
  end

  # Other scopes may use custom stacks.
  # scope "/api", PtodosWeb do
  #   pipe_through :api
  # end
end
