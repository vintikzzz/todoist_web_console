defmodule Todoist.OAuth do
  @moduledoc """
  An OAuth2 strategy for Todoist
  """
  use OAuth2.Strategy
  alias OAuth2.Strategy.AuthCode

  defp config do
    [
      strategy: Todoist.OAuth,
      site: "https://todoist.com",
      authorize_url: "/oauth/authorize",
      token_url: "/oauth/access_token"
    ]

  end
  # Public API

  def client(opts \\ []) do
    Application.get_env(:todoist_web_console, Todoist.OAuth)
    |> Keyword.merge(config())
    |> Keyword.merge(opts)
    |> IO.inspect
    |> OAuth2.Client.new()
  end

  def authorize_url!(params \\ []) do
    OAuth2.Client.authorize_url!(client(), params)
  end

  def get_token!(params \\ [], _headers \\ []) do
    OAuth2.Client.get_token!(client(), params)
  end

  # Strategy Callbacks

  def authorize_url(client, params) do
    AuthCode.authorize_url(client, params)
  end

  def get_token(client, params, headers) do
    client
    |> put_header("Accept", "application/json")
    |> put_param(:client_secret, client.client_secret)
    |> AuthCode.get_token(params, headers)
  end

end
