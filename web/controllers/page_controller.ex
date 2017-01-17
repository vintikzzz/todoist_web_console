defmodule TodoistWebConsole.PageController do
  use TodoistWebConsole.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end

  def console(conn, _params) do
    render conn, "console.html"
  end
end
