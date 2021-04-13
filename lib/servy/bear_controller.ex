defmodule Servy.BearController do

  alias Servy.Wildthings
  alias Servy.Bear

  import Servy.View, only: [render: 4, render: 3]

  def index(conv) do
    bears =
      Wildthings.list_bears()
      |> Enum.sort(&Bear.order_asc_by_name/2)

    render(conv, 200, "index.eex", bears: bears)
  end

  def show(conv, %{"id" => id}) do
    bear = Wildthings.get_bear(id)
    render(conv, 200, "show.eex", bear: bear)
  end

  def delete(conv, _params) do
    render(conv, 403, "delete.eex")
  end

  def create(conv, %{"name" => name, "type" => type}) do
    %{ conv | status: 201,
      resp_body: "Created a #{type} bear named #{name}!" }
  end

end

