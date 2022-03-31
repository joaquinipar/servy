defmodule Servy.PledgeController do

  alias Servy.PledgeServer
  alias Servy.View

  def create(conv, %{"name" => name, "amount" => amount}) do
    # Sends the pledge to the external service and caches it
    pledge_response = Servy.PledgeServer.create_pledge(name, String.to_integer(amount))
    %{ conv | status: 201, resp_body: ~s(#{name} pledged #{amount}! <a href="/pledges">Return</a>)  }
  end

  def index(conv) do
    # Gets the recent pledges from the cache
    pledges = PledgeServer.recent_pledges()
    View.render(%{ conv | status: 200}, "pledges.eex", pledges: pledges)
  end

  def get_create(conv) do
    View.render(%{ conv | status: 200}, "create_pledge.eex")
  end
end
