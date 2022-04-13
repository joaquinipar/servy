defmodule Servy.PledgeServer do

  @pledge_server_pid :pledge_server_pid # a constant
  @external_service_url "https://httparrot.herokuapp.com"

  use GenServer

  defmodule State do
    defstruct cache_size: 3, pledges: []
  end

  #def child_spec(arg) do
  #  # Customize start
  #  %{id: Servy.PledgeServer, restart: :temporary, shutdown: 5000,
  #  start: {Servy.PledgeServer, :start_link, [[]], type: :worker}}
  #end

  def start_link(_arg) do
    IO.puts "Starting the Pledge server..."
    GenServer.start_link(__MODULE__,%State{}, name: @pledge_server_pid)
    # spawn the GenServer process and link it to the process that calls this function
  end

  # Client Process

  def create_pledge( name, amount) do
    GenServer.call @pledge_server_pid, {:create_pledge, name, amount}
  end

  def recent_pledges() do
    # Returns the most recent pledges (cache)
    GenServer.call @pledge_server_pid, :recent_pledges
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
    GenServer.call @pledge_server_pid, :total_pledged
  end

  def clear do
    GenServer.cast @pledge_server_pid, :clear
  end

  def set_cache_size(size) do
    GenServer.cast @pledge_server_pid, {:set_cache_size, size}
  end

  # Server Callbacks

  def init(state) do
    pledges = fetch_recent_pledges_from_service()
    new_state = %{state | pledges: pledges}
    {:ok, new_state}
  end

  def handle_cast(:clear, state) do
    {:noreply, %{ state | pledges: []} }
  end

  def handle_cast({:set_cache_size, size}, state) do
    new_state = %{ state | cache_size: size}
    {:noreply, new_state}
  end

  def handle_call({:create_pledge, name, amount}, _from, %Servy.PledgeServer.State{pledges: pledges, cache_size: cache_size} = state) do
    case send_pledge_to_service(name, amount) do
      {:ok, id} -> # Save pledge to cache
        IO.puts "----------------"
        IO.inspect(state)
        recent_pledges = Enum.take(pledges, cache_size - 1)
        cached_pledges = [ {name, amount} | recent_pledges]
        IO.puts "---------------------"
        IO.inspect state
        new_state = %{ state | pledges: cached_pledges}
        IO.inspect new_state
        IO.puts "New state is #{inspect new_state}"
        IO.puts "#{name} pledged #{amount}!"
        {:reply, id, new_state}
      {:error, reason} ->
        IO.puts "An error ocurred. '#{reason.reason}'"
        {:reply, reason, state}
    end
  end

  def handle_call(:recent_pledges, _from, state) do
    IO.puts "Sent recent pledges.."
    {:reply, state.pledges, state}
  end

  def handle_call(:total_pledged, _from, state) do
    total_pledged =
      state.pledges
      |> Enum.map(fn ({_, amount}) -> amount end)
      |> Enum.sum
    IO.puts "Sent total pledges (#{total_pledged}).."
    {:reply, total_pledged, state}
  end

  # handle_info handles unexpected messages
  def handle_info(message, state) do
    IO.puts "You cannot touch this! #{inspect message}"
    {:noreply, state}
  end

  def fetch_recent_pledges_from_service do
    #Mock...
    [{"Dom", 15}, {"Wilson",25}]
  end
end

#alias Servy.PledgeServer

#{:ok, pid} = PledgeServer.start()

#IO.inspect PledgeServer.create_pledge("larry", 10)
#IO.inspect PledgeServer.create_pledge("moe", 20)
#IO.inspect PledgeServer.create_pledge("curly", 30)
#IO.inspect PledgeServer.create_pledge("daisy", 40)
#IO.inspect PledgeServer.create_pledge("grace", 50)

#PledgeServer.recent_pledges()
#IO.inspect PledgeServer.total_pledged()
