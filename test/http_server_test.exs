defmodule HttpServerTest do
  use ExUnit.Case

  alias Servy.HttpServer

  defp send_request(parent, request_body) do
    spawn fn -> send(parent, HTTPoison.post(
      "http://localhost:4000/api/bears",
      request_body,
      [{"Content-Type", "application/json"}]
    ))
    end
  end

  test "check our server replies to requests" do
    # Start our HttpServer
    pid = spawn(HttpServer, :start, [4000])

    request_body = ~s({"name": "Baloo", "type": "Grizzly Pale"})
    response_body = ~s({"msg": "Created a Grizzly Pale bear named Baloo!"})

    Enum.each(1..5, fn _ ->
      send_request(self(), request_body)
    end)

    Enum.each(1..5, fn _ -> receive do
      {:ok, response} ->
        assert response.status_code == 201
        assert response.body == response_body
      end
    end)

    # End our HttpServer
    Process.exit(pid, "End Test")
  end

end
