defmodule HttpServerTest do
  use ExUnit.Case

  alias Servy.HttpServer

  defp assert_correct_response(response, response_body) do
    assert response.status_code == 201
    assert response.body == response_body
  end

  test "check our server replies to requests" do
    # Start our HttpServer
    pid = spawn(HttpServer, :start, [4001])

    headers = [{"Content-Type", "application/json"}]
    request_body = ~s({"name": "Baloo", "type": "Grizzly Pale"})
    request = ["http://localhost:4001/api/bears", request_body, headers]

    response_body = ~s({"msg": "Created a Grizzly Pale bear named Baloo!"})

    # Concurrent calls to the server
    1..5
    |> Enum.map(fn _ -> Task.async(HTTPoison, :post!, request) end)
    |> Enum.map(&Task.await/1)
    |> Enum.each(&assert_correct_response(&1, response_body))

    # End our HttpServer
    Process.exit(pid, "End Test")
  end

end
