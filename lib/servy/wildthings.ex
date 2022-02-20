defmodule Servy.Wildthings do
  alias Servy.Bear

  @bears_path Path.expand("../../resources", __DIR__)

  def list_bears do
    @bears_path
      |> Path.join("bears.json")
      |> File.read!
      |> Poison.decode!( as: %{"bears" => [%Bear{}]})
      |> Map.get("bears")
  end

  def get_bear(id) when is_integer(id) do
    Enum.find(list_bears(), fn(b) -> b.id == id end)
  end

  def get_bear(id) when is_binary(id) do
    id |> String.to_integer |> get_bear
  end

end
