defmodule TodoistWebConsole.CommandControllerTest do
  use ExUnit.Case, async: false
  use TodoistWebConsole.ConnCase
  import Mock

  test "#command returns list of items on list command", %{conn: conn} do
    items = [
      %{"id" => 1, "content" => "test"},
      %{"id" => 2, "content" => "test2"}
    ]
    with_mocks [
      {Todoist.API, [:passthrough], [sync: fn _client, _args ->
        %{"items" => items}
      end]},
    ] do
      conn = post conn, command_path(conn, :command), %{"command" => "list"}
      assert json_response(conn, 200) == items
    end
  end

  test "#command returns result for other commands as is", %{conn: conn} do
    res = %{"temp_id_mapping" => %{
        "d897729c-e9a2-435d-8922-ebd3596a8f4a"=> 78361622
      },
      "sync_status" => %{
        "947ca9dc-8984-4e55-b627-047453d519b5" => "ok"
      },
      "seq_no_global" => 10916974882,
      "seq_no"        => 10916974882
    }
    with_mocks [
      {Todoist.API, [:passthrough], [sync: fn _client, _args -> res end]},
    ] do
      conn = post conn, command_path(conn, :command), %{"command" => "create \"some awesome task\""}
      assert json_response(conn, 200) == res
    end
  end
end
