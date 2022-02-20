defmodule Servy.Api.BearController do

  def index(conv) do
    json =
      Servy.Wildthings.list_bears()
      |> Poison.encode!

      new_headers = Map.put(conv.resp_headers, "Content-Type", "application/json")

      %{conv | status: 200, resp_headers: new_headers, resp_body: json}
  end

end
