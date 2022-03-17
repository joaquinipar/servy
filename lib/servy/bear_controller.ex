defmodule Servy.BearController do

  import Servy.Wildthings
  import Servy.Bear
  import Servy.View

  alias Servy.Wildthings
  alias Servy.Bear
  alias Servy.View

  def index(conv) do
    bears =
      Wildthings.list_bears()
      |> Enum.sort(&Bear.order_asc_by_name/2)

      View.render(conv, "index.eex", bears)
  end

  def show(conv, %{"id" => id}) do
    bear = Wildthings.get_bear(id)

    View.render(conv, "show.eex", bear: bear)
  end

  def create(conv, %{"name" => name, "type" => type}) do
    %{ conv | status: 201,
              resp_body: "Created a #{type} bear named #{name}!" }
  end

end
