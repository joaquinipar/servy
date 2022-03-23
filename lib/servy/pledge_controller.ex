defmodule Servy.PledgeController do

  alias Servy.PledgeServer

  def create(conv, %{"name" => name, "amount" => amount}) do
    # Sends the pledge to the external service and caches it
    pledge_response = Servy.PledgeServer.create_pledge(name, String.to_integer(amount))
    case pledge_response do
      {:response, _} -> %{ conv | status: 201, resp_body: "#{name} pledged #{amount}!" }
      {:error, reason} -> %{ conv | status: 500, resp_body: "An error ocurred. #{reason.reason}" }
    end
  end

  def index(conv) do
    # Gets the recent pledges from the cache
    pledges = PledgeServer.recent_pledges()

    %{ conv | status: 200, resp_body: (inspect pledges) }
  end
end
