defmodule HttpServerTest do
  use ExUnit.Case

  alias Servy.HttpServer

  test "check our server replies to requests" do
    # Start our HttpServer
    pid = spawn(HttpServer, :start, [4000])

    request_body = ~s({"name": "Baloo", "type": "Grizzly Pale"})
    response_body = ~s({"msg": "Created a Grizzly Pale bear named Baloo!"})

    {:ok, response} = HTTPoison.post("http://localhost:4000/api/bears", request_body, [{"Content-Type", "application/json"}])
    assert response.status_code == 201
    assert response.body == response_body

    # End our HttpServer
    Process.exit(pid, "End Test")
  end

end
