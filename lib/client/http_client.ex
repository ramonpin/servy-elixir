defmodule Servy.HttpClient do

  def send(host, port, request) do
    {:ok, client_sock} = :gen_tcp.connect(host, port, [:binary, packet: :raw, active: false])
    :ok = :gen_tcp.send(client_sock, request)
    {:ok, response} = :gen_tcp.recv(client_sock, 0)
    :ok = :gen_tcp.close(client_sock)

    response
  end

end

