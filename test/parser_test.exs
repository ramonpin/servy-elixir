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

end
