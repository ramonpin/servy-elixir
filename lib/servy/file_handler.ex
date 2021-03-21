defmodule Servy.FileHandler do

  def handle_file(file, conv) do
    case File.read(file) do
      {:ok, content} ->
        %{ conv | resp_body: content, status: 200 }

      {:error, :enoent} ->
        %{ conv | resp_body: "File not found!!", status: 404 }

      {:error, reason} ->
        %{ conv | resp_body: "Error #{reason}", status: 500 }
    end
  end

end
