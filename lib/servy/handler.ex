defmodule Servy.Handler do

  @moduledoc "Handles HTTP requests,"
  
  @pages_path Path.expand("../../pages", __DIR__)

  import Servy.Plugins, only: [rewrite_path: 1, log: 1, track: 1]
  import Servy.Parser, only: [parse: 1]

  @doc "Transforms the request into a response"
  def handle(request) do
    request
    |> parse
    |> rewrite_path
    |> log
    |> route
    |> track
    |> format_response
  end

  def route(%{method: "GET", path: "/wildthings"} = conv) do
    %{ conv | resp_body: "Bears, Lions, Tigers", status: 200 }
  end

  def route(%{method: "GET", path: "/bears"} = conv) do
    %{ conv | resp_body: "Teddy, Paddington, Smokey", status: 200 }
  end

  def route(%{method: "GET", path: "/bears/new"} = conv) do
    @pages_path 
    |> Path.join("form.html")
    |> handle_file(conv)
  end

  def route(%{method: "GET", path: "/bears/" <> id} = conv) do
    %{ conv | resp_body: "Bear #{id}", status: 200 }
  end

  def route(%{method: "DELETE", path: "/bears/" <> _id} = conv) do
    %{ conv | resp_body: "Is forbidden to delete bears", status: 403 }
  end

  def route(%{method: "GET", path: "/about"} = conv) do
    @pages_path 
    |> Path.join("about.html")
    |> handle_file(conv)
  end

  def route(%{method: "GET", path: "/pages/" <> page} = conv) do
    @pages_path 
    |> Path.join("#{page}.html")
    |> handle_file(conv)
  end

  def route(%{path: path} = conv) do
    %{ conv | resp_body: "No #{path} here", status: 404 }
  end

  def format_response(conv) do
    # TODO: Use values in the map to create an HTTP response string
    """
    HTTP/1.1 #{conv.status} #{status_reason(conv.status)}
    Content-Type: text/html
    Content-Length: #{byte_size(conv.resp_body)}
    
    #{conv.resp_body}
    """
  end

  defp handle_file(file, conv) do
    case File.read(file) do
      {:ok, content} ->
        %{ conv | resp_body: content, status: 200 }

      {:error, :enoent} ->
        %{ conv | resp_body: "File not found!!", status: 404 }

      {:error, reason} ->
        %{ conv | resp_body: "Error #{reason}", status: 500 }
    end
  end

  defp status_reason(code) do
    %{
      200 => "OK",
      201 => "Created",
      401 => "Unauthorized",
      403 => "Forbidden",
      404 => "Not Found",
      500 => "Internal Server Error"
    }[code]
  end

end

request = """
GET /wildthings HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)

IO.puts response

request = """
GET /bears HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)

IO.puts response

request = """
GET /bigfoot HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)

IO.puts response

request = """
GET /bears/1 HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)

IO.puts response

request = """
DELETE /bears/1 HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)

IO.puts response

request = """
GET /wildlife HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)

IO.puts response

request = """
GET /bears?id=1 HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)

IO.puts response

request = """
GET /about HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)

IO.puts response

request = """
GET /bears/new HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)

IO.puts response

request = """
GET /pages/about HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)

IO.puts response

