defmodule Servy.Exercises.HttpClient do

  def client(req, port) do
    some_host_in_net = 'localhost'
    {:ok, sock} = :gen_tcp.connect(some_host_in_net, port, [:binary, packet: :raw, active: false])
    :ok = :gen_tcp.send(sock, req)
    {:ok, response} = :gen_tcp.recv(sock,0)
    IO.inspect(response)
    :ok = :gen_tcp.close(sock)
    response
  end
end
