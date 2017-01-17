defmodule TodoistWebConsole.PageControllerTest do
  use TodoistWebConsole.ConnCase

  test "#index renders page with usage help and auth button", %{conn: conn} do
    conn = get conn, page_path(conn, :index)
    assert html_response(conn, 200) =~ "Usage"
    assert html_response(conn, 200) =~ "Authorize and open console"
  end

  test "#console renders page with usage help and console for logged user", %{conn: conn} do
    conn = assign(conn, :current_user, %{"full_name" => "test"})
    conn = get conn, page_path(conn, :console)
    assert html_response(conn, 200) =~ "Usage"
    assert html_response(conn, 200) =~ "test"
    assert html_response(conn, 200) =~ command_path(conn, :command)
  end

  test "#console redirects to auth for unlogged user", %{conn: conn} do
    conn = get conn, page_path(conn, :console)
    assert redirected_to(conn) == auth_path(conn, :index)
  end
end
