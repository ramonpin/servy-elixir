defmodule Servy.Api.BearController do

  def index(conv) do
    json =
      Servy.Wildthings.list_bears
      |> Poison.encode!

    headers = %{ conv.resp_headers | "Content-Type" => "application/json" }
    %{ conv | resp_body: json, resp_headers: headers, status: 200 }
  end

  def create(conv, %{"name" => name, "type" => type}) do
    json = ~s({"msg": "Created a #{type} bear named #{name}!"})

    headers = %{ conv.resp_headers | "Content-Type" => "application/json" }
    %{ conv | resp_body: json, resp_headers: headers, status: 201 }
  end

end

