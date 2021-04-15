defmodule HttpServerTest do
  use ExUnit.Case

  alias Servy.HttpServer
  alias Servy.HttpClient

  test "check our server replies to requests" do
    request = """
    POST /api/bears HTTP/1.1\r
    Host: example.com\r
    User-Agent: ExampleBrowser/1.0\r
    Accept: */*\r
    Content-Type: application/json\r
    Content-Length: 41\r
    \r
    {"name": "Baloo", "type": "Grizzly Pale"}
    """

    response = """
    HTTP/1.1 201 Created\r
    Content-Type: application/json\r
    Content-Length: 51\r
    \r
    {"msg": "Created a Grizzly Pale bear named Baloo!"}
    """

    pid = spawn(HttpServer, :start, [4000])
    assert response == HttpClient.send('localhost', 4000, request)
    Process.exit(pid, "End Test")
  end

end
