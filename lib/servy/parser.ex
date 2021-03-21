defmodule Servy.Parser do

  @doc "Parses the request into a conversantion map."
  def parse(request) do
    [method, path, _] = 
      request 
      |> String.split("\n") 
      |> List.first
      |> String.split(" ")

    %{ method: method, 
       path: path,
       resp_body: "",
       status: nil
     }
  end

end

