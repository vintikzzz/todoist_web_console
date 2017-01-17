defmodule Todoist.API do
  def sync(client, params) do
    url = Application.get_env(:todoist_web_console, Todoist.API)[:url]

    params = params
    |> Enum.map(fn {k, v} -> {k, to_string(Poison.Encoder.encode(v, []))} end)
    |> Keyword.put_new(:token, client.token.access_token)

    OAuth2.Client.post!(client, url, params,
      [{"content-type", "application/x-www-form-urlencoded"}], []).body
  end
end
