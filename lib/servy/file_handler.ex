defmodule Servy.FileHandler do
  alias Servy.Conv

  def handle_file(file, %Conv{} = conv) do
    case File.read(file) do
      {:ok, content} ->
        %{conv | resp_body: content, status: 200}

      {:error, :enoent} ->
        %{conv | resp_body: "File not found!!", status: 404}

      {:error, reason} ->
        %{conv | resp_body: "Error #{reason}", status: 500}
    end
  end

  def handle_markdown(file, %Conv{} = conv) do
    case File.read(file) do
      {:ok, content} ->
        html = Earmark.as_html!(content, escape: false)
        %{conv | resp_body: html, status: 200}

      {:error, :enoent} ->
        %{conv | resp_body: "File not found!!", status: 404}

      {:error, reason} ->
        %{conv | resp_body: "Error #{reason}", status: 500}
    end
  end
end
