defmodule Servy.HttpServer do

  require Logger

  @doc """
  Starts the server on the given `port` of localhost.
  """
  def start(port) when is_integer(port) and port > 1023 do
    {:ok, listen_socket} =
      :gen_tcp.listen(port, [:binary, packet: :raw, active: false, reuseaddr: true])

    log_info "Listening for connection requests on port #{port}..."

    accept_loop(listen_socket)
  end

  @doc """
  Accepts client connections on the `listen_socket`.
  """
  def accept_loop(listen_socket) do
    log_info "Waiting to accept a client connection..."
    {:ok, client_socket} = :gen_tcp.accept(listen_socket)

    log_info "Connection accepted!"
    pid = spawn(__MODULE__, :serve, [client_socket])

    # Transfer ownership of the socket to the spawned process
    # so if this process dies the socket gets closed automagically
    :ok = :gen_tcp.controlling_process(client_socket, pid)

    accept_loop(listen_socket)
  end

  @doc """
  Receives the request on the `client_socket` and
  sends a response back over the same socket.
  """
  def serve(client_socket) do
    client_socket
    |> read_request
    |> Servy.Handler.handle
    |> write_response(client_socket)
  end

  @doc """
  Recieves a request on the `client_socket`.
  """
  def read_request(client_socket) do
    {:ok, request} = :gen_tcp.recv(client_socket, 0) # all available bytes

    log_info """
    Recieved request:
    #{request}
    --------------------------------
    """

    request
  end

  @doc """
  Generates a generic HTTP response
  """
  def generate_response(_request) do
    """
    HTTP/1.1 200 OK\r
    Content-Type: text/plain\r
    Content-Length: 6\r
    \r
    Hello!
    """
  end

  @doc """
  Sends the `response` over the `client_socket`.
  """
  def write_response(response, client_socket) do
    :ok = :gen_tcp.send(client_socket, response)

    log_info """
    Sent response:
    #{response}
    --------------------------------
    """

    :gen_tcp.close(client_socket)
  end

  defp log_info(msg) do
    if Mix.env != :test, do: Logger.info(msg)
  end

end

