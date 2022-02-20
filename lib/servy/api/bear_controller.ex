defmodule Servy.Api.BearController do

  alias Servy.Conv

  def index(conv) do
    json =
      Servy.Wildthings.list_bears()
      |> Poison.encode!

      new_headers = Map.put(conv.resp_headers, "Content-Type", "application/json")

      %{conv | status: 200, resp_headers: new_headers, resp_body: json}
  end

  def create(%Conv{method: "POST", params: params, resp_headers: resp_headers} = conv) do

    new_headers = Map.put(resp_headers, "Content-Type", "text/html")
    %Conv{ conv | status: 201, resp_headers: new_headers, resp_body: "Created a #{params["type"]} bear named #{params["name"]}!"}
  end

end
