defmodule Servy.Counter do

  @server_pid :server_pid

  use GenServer

  # Client

  def start do
  GenServer.start(__MODULE__, %{}, name: @server_pid)
  end

  def bump_counter(route) do
    GenServer.call @server_pid, {:bump_counter, route}
  end

  def get_count(route) do
    GenServer.call @server_pid, {:get_misses, route}
  end

  def get_counts do
    GenServer.call @server_pid, {:get_all_misses}
  end


  # Server Callbacks

  def handle_call({:bump_counter, route}, _from, state) when is_map_key(state, route) do
    %{^route => misses} = state
    new_state = Map.put(state, route, misses + 1)
    {:reply, misses + 1, new_state}
  end

  def handle_call({:bump_counter, route}, _from, state) do
    new_state = Map.put(state, route, 1)
    {:reply, 1, new_state}
  end

  def handle_call({:get_misses, route}, _from, state) when is_map_key(state, route) do
    {:reply, state[route], state}
  end

  def handle_call({:get_misses, _}, _from, state), do: {:reply, 0, state}

  def handle_call({:get_all_misses}, _from, state) do
    {:reply, state, state}
  end

end
