defmodule TodoistWebConsole.Router do
  use TodoistWebConsole.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :assign_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug :fetch_session
  end

  scope "/", TodoistWebConsole do
    pipe_through :browser # Use the default browser stack

    get "/",        PageController, :index
    get "/console", PageController, :console
  end

  scope "/auth", TodoistWebConsole do
    pipe_through :browser

    get    "/",         AuthController, :index
    get    "/callback", AuthController, :callback
    delete "/logout",   AuthController, :delete
  end

  # Other scopes may use custom stacks.
  scope "/api", TodoistWebConsole do
    pipe_through :api

    post "/command", CommandController, :command
  end

  defp assign_current_user(conn, _) do
    case Map.has_key?(conn.assigns, :current_user) do
      true -> conn
      _    -> assign(conn, :current_user, get_session(conn, :current_user))
    end
  end
end
