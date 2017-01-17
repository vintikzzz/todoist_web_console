defmodule TodoistWebConsole.AuthController do
  use TodoistWebConsole.Web, :controller

  def index(conn, _params) do
    state = get_csrf_token()
    conn
    |> put_session(:oauth_state, state)
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

  def callback(conn, %{"code" => code, "state" => state}) do
    case get_session(conn, :oauth_state) == state do
      true -> authorize(conn, code)
      _ -> conn |> put_status(400)
    end
  end

  defp authorize(conn, code) do
    # Exchange an auth code for an access token
    client = Todoist.OAuth.get_token!(code: code)

    # Request the user's data with the access token
    user = get_user!(client)

    # Store the user in the session under `:current_user` and redirect to /.
    # In most cases, we'd probably just store the user's ID that can be used
    # to fetch from the database. In this case, since this example app has no
    # database, I'm just storing the user map.
    #
    # If you need to make additional resource requests, you may want to store
    # the access token as well.
    conn
    |> put_session(:current_user, user)
    |> put_session(:access_token, client.token.access_token)
    |> redirect(to: "/console")
  end

  defp get_user!(client) do
    Todoist.API.sync(client, sync_token: "*", resource_types: ["user"])["user"]
  end
end
