defmodule Servy.HttpClient do

  def client(req) do
    some_host_in_net = 'localhost'
    {:ok, sock} = :gen_tcp.connect(some_host_in_net, 5678, [:binary, packet: :raw, active: false])
    :ok = :gen_tcp.send(sock, req)
    {:ok, response} = :gen_tcp.recv(sock,0)
    IO.inspect(response)
    :ok = :gen_tcp.close(sock)
  end
end
