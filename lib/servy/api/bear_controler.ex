defmodule Servy.Api.BearController do

  def index(conv) do
    json =
      Servy.Wildthings.list_bears
      |> Poison.encode!
    %{ conv | resp_body: json, resp_content_type: "application/json", status: 200 }
  end

  def create(conv, %{"name" => name, "type" => type}) do
    json = "{\"msg\": \"Created a #{type} bear named #{name}!\"}"
    %{ conv | resp_body: json, resp_content_type: "application/json", status: 201 }
  end

end

