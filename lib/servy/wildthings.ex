defmodule Servy.Wildthings do
  alias Servy.Bear

  @db_dir_path Path.expand("db", File.cwd!())
  @db_file_path Path.join(@db_dir_path, "wildthings.json")

  def list_bears do
    @db_file_path
    |> File.read!()
    |> Poison.decode!(as: %{"bears" => [%Bear{}]})
    |> Map.get("bears")
  end

  def get_bear(id) when is_integer(id) do
    Enum.find(list_bears(), &(&1.id == id))
  end

  def get_bear(id) when is_binary(id) do
    id |> String.to_integer() |> get_bear
  end
end
