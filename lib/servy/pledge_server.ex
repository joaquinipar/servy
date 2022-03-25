defmodule Servy.PledgeServer do

  @pledge_server_pid :pledge_server_pid # a constant
  @external_service_url "https://httparrot.herokuapp.com"

  alias Servy.GenericServer

  def start do
    GenericServer.start_server(__MODULE__,[], @pledge_server_pid)
  end

  # Client Process

  def create_pledge( name, amount) do
    GenericServer.call @pledge_server_pid, {:create_pledge, name, amount}
  end

  def recent_pledges() do
    # Returns the most recent pledges (cache)
    GenericServer.call @pledge_server_pid, :recent_pledges
  end

  defp send_pledge_to_service(name, amount) do
    # Sends pledge to external service...
    IO.puts "Sending to external service.."

    post_result = HTTPoison.post("#{@external_service_url}/post", Poison.encode!(%{name: name,amount: amount}))

    case post_result do
      {:ok, _} -> {:ok, "pledge-#{:rand.uniform(1000)}"}
      {:error, reason} -> {:error, reason}
    end
  end

  def total_pledged do
    GenericServer.call @pledge_server_pid, :total_pledged
  end

  def clear do
    GenericServer.cast @pledge_server_pid, :clear
  end

  # Server Callbacks



  def handle_cast(:clear, _state) do
    []
  end

  def handle_call({:create_pledge, name, amount}, state) do
    case send_pledge_to_service(name, amount) do
      {:ok, id} -> # Save pledge to cache
        recent_pledges = Enum.take(state, 2)
        new_state = [ {name, amount} | recent_pledges]
        IO.puts "New state is #{inspect new_state}"
        IO.puts "#{name} pledged #{amount}!"
        {new_state, {:response, id}}
      {:error, reason} ->
        IO.puts "An error ocurred. '#{reason.reason}'"
        {state, {:error, reason}}
    end
  end

  def handle_call(:recent_pledges, state) do
    IO.puts "Sent recent pledges.."
    {state, {:response, state}}
  end

  def handle_call(:total_pledged, state) do
    total_pledged =
      state
      |> Enum.map(fn ({_, amount}) -> amount end)
      |> Enum.sum
    IO.puts "Sent total pledges (#{total_pledged}).."
    {state, {:response, total_pledged}}
  end

end

#alias Servy.PledgeServer

#pid = PledgeServer.start_server()

#IO.inspect PledgeServer.create_pledge("larry", 10)
#IO.inspect PledgeServer.create_pledge("moe", 20)
#IO.inspect PledgeServer.create_pledge("curly", 30)
#IO.inspect PledgeServer.create_pledge("daisy", 40)
#IO.inspect PledgeServer.create_pledge("grace", 50)

#PledgeServer.recent_pledges()
#IO.inspect PledgeServer.total_pledged()
