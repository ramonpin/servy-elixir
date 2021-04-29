defmodule HttpServerTest do
  use ExUnit.Case

  defp assert_correct_response(response, response_body) do
    assert response.status_code == 201
    assert response.body == response_body
  end

  test "check our server replies to requests" do
    port = Application.get_env(:servy, :port)
    headers = [{"Content-Type", "application/json"}]
    request_body = ~s({"name": "Baloo", "type": "Grizzly Pale"})
    request = ["http://localhost:#{port}/api/bears", request_body, headers]

    response_body = ~s({"msg": "Created a Grizzly Pale bear named Baloo!"})

    # Concurrent calls to the server
    1..5
    |> Enum.map(fn _ -> Task.async(HTTPoison, :post!, request) end)
    |> Enum.map(&Task.await/1)
    |> Enum.each(&assert_correct_response(&1, response_body))
  end

end
