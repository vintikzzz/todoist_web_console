defmodule TodoistWebConsole.CommandTest do
  use ExUnit.Case
  alias TodoistWebConsole.Command

  test "#parse produces command name and args from string" do
    assert Command.parse("list")                         == {:list, []}
    assert Command.parse("create something")             == {:create, ["something"]}
    assert Command.parse("create something awesome")     == {:create, ["something", "awesome"]}
    assert Command.parse("create \"something awesome\"") == {:create, ["something awesome"]}
    assert Command.parse("create 'something awesome'")   == {:create, ["something awesome"]}
    assert Command.parse("")                             == {nil, []}
  end
end
