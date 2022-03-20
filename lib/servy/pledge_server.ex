defmodule Servy.PledgeServer do

  @pledge_server_pid :pledge_server_pid # a constant

  def start_server do
    IO.puts "Starting the Pledge Server."
    pid = spawn(__MODULE__, :listen_loop, [[]])
    Process.register(pid, :pledge_server_pid) # to avoid sending the server's pid in every function argument
    pid
  end

  # Client Process

  def create_pledge( name, amount) do
    send @pledge_server_pid, {self(), :create_pledge, name, amount}

    receive do {:response, status} -> status end
  end

  def recent_pledges() do
    # Returns the most recent pledges (cache)
    send @pledge_server_pid, :recent_pledges


    receive do {:response, pledges} -> pledges end
  end

  defp send_pledge_to_service(_name, _amount) do
    # Sends pledge to external service...

    {:ok, "pledge-#{:rand.uniform(1000)}"}
  end

  def total_pledged do
    send @pledge_server_pid, {self(), :total_pledged}

    receive do
      {:response, total_pledged} -> total_pledged
    end
  end

  # Server process

  def listen_loop(state \\ []) do
    IO.puts "\nWaiting for a message.."

    receive do
      {sender, :create_pledge, name, amount} ->
        {:ok, id} = send_pledge_to_service(name, amount)
        # Save pledge to cache
        recent_pledges = Enum.take(state, 2)
        new_state = [ {name, amount} | recent_pledges]
        IO.puts "New state is #{inspect new_state}"
        IO.puts "#{name} pledged #{amount}!"
        send sender, {:response, id}
        listen_loop(new_state)

        {sender ,:recent_pledges} ->
          send sender, {:response, state}
          IO.puts "Sent recent pledges to #{inspect sender}"
          listen_loop(state)

        {sender, :total_pledged} ->
          total_pledged =
            state
            |> Enum.map(fn ({_, amount}) -> amount end)
            |> Enum.sum
          IO.puts "Sent total pledges (#{total_pledged}) to #{inspect sender}"
          send sender, {:response, total_pledged}
          listen_loop(state)

          unexpected ->
            IO.puts "Unexpected message #{inspect unexpected}"
            listen_loop(state)
    end


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
