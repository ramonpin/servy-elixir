defmodule Servy.PledgeController do
  alias Servy.PledgeServer

  import Servy.View, only: [render: 4, render: 3]

  def create(conv, %{"name" => name, "amount" => amount}) do
    PledgeServer.create_pledge(name, String.to_integer(amount))

    # %{ conv | status: 201, resp_body: "#{name} pledged #{amount}!" }
    index(conv)
  end

  def index(conv) do
    pledges = PledgeServer.recent_pledges()

    render(conv, 200, "recent_pledges.eex", pledges: pledges)
  end

  def new(conv) do
    render(conv, 200, "new_pledge.eex")
  end

  def total_pledged(conv) do
    total = PledgeServer.total_pledged()

    %{conv | status: 200, resp_body: "Total Pledged: #{total}"}
  end
end
