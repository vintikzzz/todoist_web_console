defmodule TodoistWebConsole.AuthControllerTest do
  use ExUnit.Case, async: false
  use TodoistWebConsole.ConnCase
  import Mock

  test "#index redirects to authorize url", %{conn: conn} do
    conn = get conn, auth_path(conn, :index)
    assert redirected_to(conn) =~ "https://todoist.com/oauth/authorize"
  end

  test "#logout redirects to root page", %{conn: conn} do
    conn = delete conn, auth_path(conn, :delete)
    assert redirected_to(conn) =~ page_path(conn, :index)
  end

  test "#callback authorizes user and redirects to console", %{conn: conn} do
    conn = get conn, auth_path(conn, :index)
    with_mocks [
      {Todoist.API, [:passthrough], [sync: fn _client, _args -> %{"user" => %{"full_name" => "test"}} end]},
      {Todoist.OAuth, [:passthrough], [get_token!: fn _args -> Todoist.OAuth.client(token: "abc") end]}
    ] do
      conn = get conn, auth_path(conn, :callback, %{code: 123, state: conn.assigns[:oauth_state]})
      assert redirected_to(conn) =~ page_path(conn, :console)
    end
  end

  test "#callback fails when oauth state mismatch occured", %{conn: conn} do
    conn = get conn, auth_path(conn, :index)
    conn = get conn, auth_path(conn, :callback, %{code: 123, state: "fake"})
    assert redirected_to(conn) =~ page_path(conn, :index)
  end

  test "#callback fails when authorization doesn't pass", %{conn: conn} do
    conn = get conn, auth_path(conn, :index)
    with_mocks [
      {Todoist.API, [:passthrough], [sync: fn _client, _args -> %{"user" => nil} end]},
      {Todoist.OAuth, [:passthrough], [get_token!: fn _args -> Todoist.OAuth.client(token: "abc") end]}
    ] do
      conn = get conn, auth_path(conn, :callback, %{code: 123, state: conn.assigns[:oauth_state]})
      assert redirected_to(conn) =~ page_path(conn, :index)
    end
  end
end
