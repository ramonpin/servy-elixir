defmodule ParserTest do
  use ExUnit.Case
  doctest Servy.Parser

  alias Servy.Parser

  test "parse header lines into map" do
    headers = Parser.parse_headers([
      "Content-Type: application/json",
      "Length: 560"
    ])

    expected_headers = %{
      "Content-Type" => "application/json",
      "Length" => "560"
    }

    assert expected_headers == headers
  end

  test "parse parameters urlencoded into map" do
    param_string = "name=Baloo&type=Grizzly%20Pale"
    params = Parser.parse_params("application/x-www-form-urlencoded", param_string)
    expected_params = %{"name" => "Baloo", "type" => "Grizzly Pale"}

    assert expected_params == params
  end

end

