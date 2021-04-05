defmodule Servy.Parser do

  alias Servy.Conv

  @doc "Parses the request into a conversantion map."
  def parse(request) do
    [top, param_string] = String.split(request, "\n\n")
    [request_line | header_lines] = String.split(top, "\n")
    [method, path, _] = String.split(request_line, " ")
    # headers = parse_headers(header_lines, %{})
    headers = parse_headers(header_lines)
    params = parse_params(headers["Content-Type"], param_string)

    %Conv {
      method: method,
      path: path,
      headers: headers,
      params: params
    }
  end

#   def parse_headers([head | tail], headers) do
#     [key, value] = String.split(head, ": ")
#     headers = Map.put(headers, key, value)
#     parse_headers(tail, headers)
#   end
#
#   def parse_headers([], headers), do: headers

#   def parse_headers(headers) do
#     headers
#     |> Enum.map(&String.split(&1, ": "))
#     |> Enum.reduce(%{}, &Map.put(&2, hd(&1), hd(tl(&1))))
#   end

  def parse_headers(headers) do
    Enum.reduce(headers, %{}, fn(header, headers_map) ->
      [key, value] = String.split(header, ": ")
      Map.put(headers_map, key, value)
    end)
  end

  def parse_params("application/x-www-form-urlencoded", param_string) do
    param_string |> String.trim |> URI.decode_query
  end

  def parse_params(_, _), do: %{}

end

