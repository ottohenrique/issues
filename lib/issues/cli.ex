defmodule Issues.CLI do

  @default_count 4

  import Issues.TableFormatter, only: [print_table_for_columns: 2]

  @moduledoc """
  Handle the command line parsing and the dispatch to the varios
  functions that end up generating a table of the
  last _n_ issues in a github project
  """

  def main(argv) do
    argv
    |> parse_args
    |> process
  end

  def process(:help) do
    IO.puts """
    Some help pls...
    """
  end

  def process({ user, project, count }) do
    Issues.GithubIssues.fetch(user, project)
    |> decode_response
    |> sort_into_ascending_order
    |> Enum.take(count)
    |> print_table_for_columns(["number", "created_at", "title"])
  end

  def sort_into_ascending_order(list_of_issues) do
    list_of_issues
    |> Enum.sort(&(Map.get(&1, "created_at") <= Map.get(&2, "created_at")))
  end

  def decode_response({ :ok, body }), do: body

  def decode_response({ :error, error }) do
    message = Map.get(error, "message")

    IO.puts "Error fetching from github: #{message}"
    System.halt(2)
  end

  def parse_args(argv) do
    parse = OptionParser.parse(argv, switches: [ help: :boolean ],
                                    aliases: [ h: :help ])

    case parse do
      { [ help: true ], _, _ } ->
        :help

      { _, [user, project, count], _ } ->
        { user, project, String.to_integer(count) }

      { _, [user, project], _ } ->
        { user, project, @default_count }

      _ ->
        :help
    end
  end
end
