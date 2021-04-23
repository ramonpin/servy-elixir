defmodule Servy.PledgeServer do

  alias Servy.GenericServer

  @name __MODULE__
  @num_pledges 3

  def start(initial \\ %{pledges: [], total: 0}) do
    GenericServer.start(__MODULE__, initial, @name)
  end

  # Client interface functions
  def create_pledge(name, amount) do
    GenericServer.call @name, {:create_pledge, name, amount}
  end

  def recent_pledges do
    GenericServer.call @name, :recent_pledges
  end

  def total_pledged do
    GenericServer.call @name, :total_pledged
  end

  def clear do
    GenericServer.cast @name, :clear
  end

  # Handle calls
  def handle_call(:recent_pledges, state), do: {state.pledges, state}
  def handle_call(:total_pledged, state), do: {state.total, state}

  def handle_call({:create_pledge, name, amount}, state) do
    {:ok, id}  = send_pledge_to_service(name, amount)

    new_pledges = [ {id, name, amount} | state.pledges ] |> Enum.take(@num_pledges)
    new_total = state.total + amount
    new_state = %{ state | pledges: new_pledges, total: new_total}

    {id, new_state}
  end

  defp send_pledge_to_service(_name, _amount) do
    # CODE TO SEND PLEDGE TO EXTERNAL SERVICE PENDING
    Process.sleep(100)
    {:ok, "pledge-#{:rand.uniform(10_000)}"}
  end

  def handle_cast(:clear, _state) do
    %{pledges: [], total: 0}
  end

end

