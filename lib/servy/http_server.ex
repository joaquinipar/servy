defmodule Servy.HttpServer do
  def server do

      {ok, lsock} = :gen_tcp.listen(5678, [:binary, packet: 0,
                                          active: false])
      {ok, sock} = :gen_tcp.accept(lsock)
      {ok, bin} = :gen_tcp.recv(sock, 0)
      #{ok, bin} = do_recv(sock, [])
      :ok = :gen_tcp.close(sock)
      bin
  end
end
