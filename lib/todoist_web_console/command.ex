defmodule TodoistWebConsole.Command do
  def parse(command) do
    [command | args] = Regex.scan(~r/"([^"]*)"|'([^']*)'|[^\s]+/, command, [])
    |> Enum.map(fn e ->  List.last(e) end)
    {String.to_atom(command), args}
  end
end
