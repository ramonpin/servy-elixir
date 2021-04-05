defmodule Servy.BearController do

  alias Servy.Wildthings
  alias Servy.Bear

  defp item(bear) do
    "<li>#{bear.name} - #{bear.type}</li>"
  end

  def index(conv) do
    bears = 
      Wildthings.list_bears() 
      |> Enum.filter(&Bear.is_grizzly?/1)
      |> Enum.sort(&Bear.order_asc_by_name/2)
      |> Enum.map(&item/1)
      |> Enum.join
    %{ conv | resp_body: "<ul>#{bears}</ul>", status: 200 }
  end

  def show(conv, %{"id" => id}) do
    bear = Wildthings.get_bear(id)
    %{ conv | resp_body: "<h1>Bear #{bear.id}: #{bear.name}</h1>", status: 200 }
  end

  def delete(conv, _params) do
    %{ conv | resp_body: "Is forbidden to delete bears", status: 403 }
  end

  def create(conv, %{"name" => name, "type" => type}) do
    %{ conv | status: 201,
      resp_body: "Create a #{type} bear named #{name}!" }
  end

end

