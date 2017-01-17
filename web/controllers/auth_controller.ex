defmodule TodoistWebConsole.AuthController do
  use TodoistWebConsole.Web, :controller

  def index(conn, _params) do
    state = get_csrf_token()
    conn
    |> put_session(:oauth_state, state)
    |> assign(:oauth_state, state)
    |> redirect external: Todoist.OAuth.authorize_url!(
      scope: "data:read_write,data:delete",
      state: state
    )
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "You have been logged out!")
    |> configure_session(drop: true)
    |> redirect(to: "/")
  end

  def callback(conn, %{"user" => user}) when is_nil(user) do
    conn
    |> put_flash(:info, "Authorization error!")
    |> redirect(to: page_path(conn, :index))
  end
  def callback(conn, %{"user" => user, "access_token" => access_token}) do
    conn
    |> put_session(:current_user, user)
    |> put_session(:access_token, access_token)
    |> put_flash(:info, "You have been logged in!")
    |> redirect(to: page_path(conn, :console))
  end
  def callback(conn, %{"state" => state, "stored_state" => stored_state}) when state != stored_state do
    conn
    |> put_flash(:info, "Wrong OAuth state provided!")
    |> redirect(to: page_path(conn, :index))
  end
  def callback(conn, %{"code" => code, "state" => state, "stored_state" => stored_state} = args) when state == stored_state do
    # Exchange an auth code for an access token
    client = Todoist.OAuth.get_token!(code: code)
    # Request the user's data with the access token
    user = get_user!(client)

    args = args
    |> Map.put("user", user)
    |> Map.put("access_token", client.token.access_token)
    callback(conn, args)
  end
  def callback(conn, args) do
    callback(conn, Map.put(args, "stored_state", get_session(conn, :oauth_state)))
  end

  defp authorize(conn, code) do
    # Exchange an auth code for an access token
    client = Todoist.OAuth.get_token!(code: code)

    # Request the user's data with the access token
    user = get_user!(client)

    # Store user data and OAuth access token
    conn
    |> put_session(:current_user, user)
    |> put_session(:access_token, client.token.access_token)
  end

  defp get_user!(client) do
    Todoist.API.sync(client, sync_token: "*", resource_types: ["user"])["user"]
  end
end
