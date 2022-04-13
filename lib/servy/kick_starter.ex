defmodule Servy.KickStarter do

  use GenServer

  # Client

  def start_link(_arg) do
    IO.puts "Starting the kickstarter.."
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def get_server do
    GenServer.call __MODULE__, :get_server
  end

  # Server Callbacks

  def init(:ok) do
    # Any exit signals propagated from the linked processes won't crash the KickStarter process
    Process.flag(:trap_exit, true)
    server_pid = start_server()
    {:ok, server_pid}
  end

  def handle_info({:EXIT, _pid, reason}, _state) do
    IO.puts "HttpServer exited (#{inspect reason})"
    server_pid = start_server()
    {:noreply, server_pid}
  end

  def handle_call(:get_server, _from, state), do: {:reply, state, state}

  def handle_call(:ping, _from,  state), do: {:reply, :pong, state}

  defp start_server do
    IO.puts "Starting the HTTP server..."
    # KickStarter process is linked to HttpServer process
    port = Application.get_env(:servy, :port)
    server_pid = spawn_link(Servy.HttpServer, :start, [port]) # Process.link(server_pid)
    Process.register(server_pid, :http_server)
    server_pid
  end

end
