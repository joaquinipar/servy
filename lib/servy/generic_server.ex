defmodule Servy.GenericServer do

  alias Servy.PledgeServer

  def start_server(callback_module,initial_state, name) do
    IO.puts "Starting Server."
    pid = spawn(__MODULE__, :listen_loop, [initial_state, callback_module])
    Process.register(pid, name) # to avoid sending the server's pid in every function argument
    pid
  end

  def call(pid, message) do
    send pid, {:call, self(), message}

    receive do
      {:response, response} -> response
      {:error, reason} -> {:error, reason}
    end
  end

  def cast(pid, message) do
    send pid, {:cast, message}
  end

  def listen_loop(state \\ [], callback_module) do
    IO.puts "\nWaiting for a message.."

    receive do
      {:call ,sender, message} when is_pid(sender) ->
        {new_state, response} = callback_module.handle_call(message, state)
        send sender, response
        listen_loop(new_state, callback_module)
      {:cast, message} ->
        new_state = callback_module.handle_cast(message, state)
        listen_loop(new_state, callback_module)
      unexpected ->
        IO.puts "Unexpected message #{inspect unexpected}"
        listen_loop(state, callback_module)
    end
  end
end
