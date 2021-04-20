defmodule Servy.Handler do

  @moduledoc "Handles HTTP requests,"

  @pages_path Path.expand("pages", File.cwd!)

  alias Servy.Conv
  alias Servy.BearController
  alias Servy.Api
  alias Servy.Fetcher

  import Servy.Plugins, only: [rewrite_path: 1, log: 1, track: 1]
  import Servy.Parser, only: [parse: 1]
  import Servy.FileHandler, only: [handle_file: 2, handle_markdown: 2]

  @doc "Transforms the request into a response"
  def handle(request) do
    request
    |> parse
    |> rewrite_path
    |> log
    |> route
    |> track
    |> put_content_length
    |> format_response
  end

  def route(%Conv{method: "GET", path: "/sensors"} = conv) do
    # Launch the three snapshots each in their own process
    snp1 = Fetcher.async(fn -> Servy.VideoCam.get_snapshot("cam-1") end)
    snp2 = Fetcher.async(fn -> Servy.VideoCam.get_snapshot("cam-2") end)
    snp3 = Fetcher.async(fn -> Servy.VideoCam.get_snapshot("cam-3") end)
    bgft = Fetcher.async(fn -> Servy.Tracker.get_location("bigfoot") end)

    # Await results
    snapshot1 = Fetcher.await(snp1)
    snapshot2 = Fetcher.await(snp2)
    snapshot3 = Fetcher.await(snp3)
    where_is_bigfoot   = Fetcher.await(bgft)

    # Result
    sensors =  inspect {[snapshot1, snapshot2, snapshot3], where_is_bigfoot}

    %{ conv | status: 200, resp_body: sensors }
  end

  def route(%Conv{method: "GET", path: "/hibernate/" <> time} = conv) do
    time |> String.to_integer |> :timer.sleep
    %{ conv | resp_body: "Awake!", status: 200 }
  end

  def route(%Conv{method: "GET", path: "/kaboom"} = _conv) do
    raise "Kaboom!"
  end

  def route(%Conv{method: "GET", path: "/wildthings"} = conv) do
    %{ conv | resp_body: "Bears, Lions, Tigers", status: 200 }
  end

  def route(%Conv{method: "GET", path: "/bears"} = conv) do
    BearController.index(conv)
  end

  def route(%Conv{method: "GET", path: "/api/bears"} = conv) do
    Api.BearController.index(conv)
  end

  def route(%Conv{method: "GET", path: "/bears/new"} = conv) do
    @pages_path
    |> Path.join("form.html")
    |> handle_file(conv)
  end

  def route(%Conv{method: "GET", path: "/bears/" <> id} = conv) do
    params = Map.put(conv.params, "id", id)
    BearController.show(conv, params)
  end

  def route(%Conv{method: "DELETE", path: "/bears/" <> id} = conv) do
    params = Map.put(conv.params, "id", id)
    BearController.delete(conv, params)
  end

  def route(%Conv{method: "POST", path: "/bears"} = conv) do
    BearController.create(conv, conv.params)
  end

  def route(%Conv{method: "POST", path: "/api/bears"} = conv) do
    Api.BearController.create(conv, conv.params)
  end

  def route(%Conv{method: "GET", path: "/about"} = conv) do
    @pages_path
    |> Path.join("about.html")
    |> handle_file(conv)
  end

  def route(%Conv{method: "GET", path: "/faq"} = conv) do
    @pages_path
    |> Path.join("faq.md")
    |> handle_markdown(conv)
  end

  def route(%Conv{method: "GET", path: "/pages/" <> page} = conv) do
    @pages_path
    |> Path.join("#{page}.html")
    |> handle_file(conv)
  end

  def route(%Conv{path: path} = conv) do
    %{ conv | resp_body: "No #{path} here!", status: 404 }
  end

  def format_response(%Conv{} = conv) do
    """
    HTTP/1.1 #{Conv.full_status(conv)}\r
    #{format_response_headers(conv)}
    \r
    #{conv.resp_body}
    """
  end

  defp format_response_headers(%Conv{} = conv) do
    for {key, value} <- conv.resp_headers do
      "#{key}: #{value}\r"
    end |> Enum.sort |> Enum.reverse |> Enum.join("\n")
  end

  def put_content_length(%Conv{} = conv) do
    put_in(conv.resp_headers["Content-Length"], byte_size(conv.resp_body))
    #new_headers = Map.put(conv.resp_headers, "Content-Length", byte_size(conv.resp_body))
    #%{ conv | resp_headers: new_headers}
  end

end

