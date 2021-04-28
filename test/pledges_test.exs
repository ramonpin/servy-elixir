defmodule PledgesTest do
  use ExUnit.Case

  alias Servy.PledgeServer

  setup_all _context do
    # This is just a try. You only need to return the :ok atom
    # to make it work.
    [ok: PledgeServer.start]
  end

  test "Pledge Server logic works as expected" do
    id1 = PledgeServer.create_pledge("ramon",  10)
    id2 = PledgeServer.create_pledge("nerea",  20)
    id3 = PledgeServer.create_pledge("thalia", 30)

    pledges = PledgeServer.recent_pledges()
    assert length(pledges) == 3
    assert {id3, "thalia", 30} == Enum.at(pledges, 0)
    assert {id2, "nerea",  20} == Enum.at(pledges, 1)
    assert {id1, "ramon",  10} == Enum.at(pledges, 2)
    assert PledgeServer.total_pledged() == 60

    id4 = PledgeServer.create_pledge("juan", 40)
    pledges = PledgeServer.recent_pledges()
    assert length(pledges) == 3
    assert {id4, "juan",   40} == Enum.at(pledges, 0)
    assert {id3, "thalia", 30} == Enum.at(pledges, 1)
    assert {id2, "nerea",  20} == Enum.at(pledges, 2)
    assert PledgeServer.total_pledged() == 100

    total_pledged = PledgeServer.total_pledged()
    assert total_pledged == 100

    PledgeServer.set_cache_size(2)
    pledges = PledgeServer.recent_pledges()
    assert length(pledges) == 2
    assert {id4, "juan",   40} == Enum.at(pledges, 0)
    assert {id3, "thalia", 30} == Enum.at(pledges, 1)
    assert PledgeServer.total_pledged() == 100

    PledgeServer.clear()
    assert PledgeServer.total_pledged() == 0
    assert PledgeServer.recent_pledges() == []
  end

end

