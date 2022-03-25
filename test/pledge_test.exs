defmodule PledgeTest do

  use ExUnit.Case

  alias Servy.PledgeServer

  ExUnit.start()

  setup do
    PledgeServer.clear()
    :ok
  end

  test "Server cache only holds last 3 pledges" do


    PledgeServer.create_pledge("larry", 10)
    PledgeServer.create_pledge("moe", 20)
    PledgeServer.create_pledge("curly", 30)
    PledgeServer.create_pledge("daisy", 40)
    PledgeServer.create_pledge("grace", 50)

    assert PledgeServer.recent_pledges() == [{"grace", 50}, {"daisy", 40}, {"curly", 30}]

  end

  test "Creates 3 pledges and then clears the cache" do
    #pid = PledgeServer.start_server()

    PledgeServer.create_pledge("larry", 10)
    PledgeServer.create_pledge("moe", 20)
    PledgeServer.create_pledge("curly", 30)
    PledgeServer.clear()

    assert PledgeServer.recent_pledges() |> Enum.empty?
  end

end
