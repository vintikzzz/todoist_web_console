defmodule TodoistWebConsole.CommandController do
  use TodoistWebConsole.Web, :controller

  def command(conn, %{"command" => command}) do
    token = get_session(conn, :access_token)
    client = Todoist.OAuth.client(token: token)
    [command | args] = Regex.scan(~r/"([^"]*)"|'([^']*)'|[^\s]+/, command, [])
    |> Enum.map(fn e ->  List.last(e) end)
    json conn, command(client, String.to_atom(command), args)
  end
  def command(client, :list, []) do
    Todoist.API.sync(client, sync_token: "*", resource_types: ["items"])["items"]
    |> Enum.map(fn e -> %{id: e["id"], content: e["content"]} end)
  end
  def command(client, :create, [content]) do
    Todoist.API.sync(client, commands: [%{
      type:    :item_add,
      uuid:    UUID.uuid4(),
      temp_id: UUID.uuid4(),
      args:    %{content: content}
    }])
  end
  def command(client, :delete, [id]) do
    Todoist.API.sync(client, commands: [%{
      type:    :item_delete,
      uuid:    UUID.uuid4(),
      args:    %{ids: [id]}
    }])
  end
  def command(client, :complete, [id]) do
    Todoist.API.sync(client, commands: [%{
      type:    :item_complete,
      uuid:    UUID.uuid4(),
      args:    %{ids: [id]}
    }])
  end
  def command(client, :reminder_add, [id, time]) do
    Todoist.API.sync(client, commands: [%{
      type:    :reminder_add,
      uuid:    UUID.uuid4(),
      temp_id: UUID.uuid4(),
      args:    %{item_id: id, service: :email, due_date_utc: time}
    }])
  end
  def command(client, :"", _), do: nil
  def command(client, _, _), do: :unknown_command
end
