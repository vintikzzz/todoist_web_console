defmodule TodoistWebConsole.PageController do
  use TodoistWebConsole.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end

  def console(conn, _params) do
    case is_nil(conn.assigns[:current_user]) do
      true -> redirect conn, to: auth_path(conn, :index)
      _    -> render conn, "console.html"
    end
  end
end
