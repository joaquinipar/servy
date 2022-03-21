defmodule Servy.Counter do

  @server_pid :server_pid

  # Client

  def start do
  pid = spawn(__MODULE__, :listen_loop, [])
  Process.register(pid, :server_pid)
  pid
  end

  def bump_counter(route) do
    send @server_pid, {self(), :bump_counter, route}

    receive do
      {:response, :ok} -> :ok
      _ -> :error
    end

  end

  def get_count(route) do
    send @server_pid, {self(), :get_misses, route}

    receive do
      {:response, misses} -> misses
      _ -> :error
     end
  end

  def get_counts do
    send @server_pid, {self(), :get_all_misses}

    receive do
      {:response, all_misses_map} ->
        all_misses_map
    end
  end


  # Server

  def listen_loop(state \\ %{}) do

    receive do
      {sender, :bump_counter, route} ->
        send sender, {:response, :ok}
        listen_loop(bump_counter(route, state))

      {sender, :get_misses, route} ->
        send sender, {:response, get_misses(route, state)}
        listen_loop(state)

      {sender, :get_all_misses} ->
        send sender, {:response, state}
        listen_loop(state)
    end
  end

  defp bump_counter(route, state) when is_map_key(state, route) do
    %{^route => misses} = state
    Map.put(state, route, misses + 1)
  end

  defp bump_counter(route, state) do
    Map.put(state, route, 1)
  end

  defp get_misses(route, state) when is_map_key(state, route) do
    state[route]
  end

  defp get_misses(_, _), do: 0

end
