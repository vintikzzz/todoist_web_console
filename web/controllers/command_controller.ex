defmodule TodoistWebConsole.CommandController do
  alias TodoistWebConsole.Command
  use TodoistWebConsole.Web, :controller

  def command(conn, %{"command" => command}) do
    token = get_session(conn, :access_token)
    client = Todoist.OAuth.client(token: token)
    json conn, command(client, Command.parse(command))
  end
  def command(client, {:list, []}) do
    Todoist.API.sync(client, sync_token: "*", resource_types: ["items"])["items"]
    |> Enum.map(fn e -> %{id: e["id"], content: e["content"]} end)
  end
  def command(client, {:create, [content]}) do
    Todoist.API.sync(client, commands: [%{
      type:    :item_add,
      uuid:    UUID.uuid4(),
      temp_id: UUID.uuid4(),
      args:    %{content: content}
    }])
  end
  def command(client, {:delete, [id]}) do
    Todoist.API.sync(client, commands: [%{
      type:    :item_delete,
      uuid:    UUID.uuid4(),
      args:    %{ids: [id]}
    }])
  end
  def command(client, {:complete, [id]}) do
    Todoist.API.sync(client, commands: [%{
      type:    :item_complete,
      uuid:    UUID.uuid4(),
      args:    %{ids: [id]}
    }])
  end
  def command(client, {:reminder_add, [id, time]}) do
    Todoist.API.sync(client, commands: [%{
      type:    :reminder_add,
      uuid:    UUID.uuid4(),
      temp_id: UUID.uuid4(),
      args:    %{item_id: id, service: :email, due_date_utc: time}
    }])
  end
  def command(_, {:"", _}), do: nil
  def command(_, {_, _}), do: :unknown_command
end
