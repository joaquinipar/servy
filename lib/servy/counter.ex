defmodule Servy.Counter do

  @server_pid :server_pid

  alias Servy.GenericServer

  # Client

  def start do
  Servy.GenericServer.start_server(__MODULE__, %{}, @server_pid)
  end

  def bump_counter(route) do
    GenericServer.call @server_pid, {:bump_counter, route}
  end

  def get_count(route) do
    GenericServer.call @server_pid, {:get_misses, route}
  end

  def get_counts do
    GenericServer.call @server_pid, {:get_all_misses}
  end


  # Server Callbacks

  def handle_call({:bump_counter, route}, state) when is_map_key(state, route) do
    %{^route => misses} = state
    {Map.put(state, route, misses + 1), {:response, misses + 1}}
  end

  def handle_call({:bump_counter, route}, state) do
    {Map.put(state, route, 1), {:response, 1}}
  end

  def handle_call({:get_misses, route}, state) when is_map_key(state, route) do
    {state, {:response , state[route]}}
  end

  def handle_call({:get_misses, _}, state), do: {state, {:response, 0}}

  def handle_call({:get_all_misses}, state) do
    {state, {:response, state}}
  end

end
