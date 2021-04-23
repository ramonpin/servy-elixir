defmodule Servy.PledgeServer do
  use GenServer

  @name __MODULE__

  defmodule State do
    defstruct num_pledges: 3, pledges: [], total: 0
  end

  def init(%State{} = initial) do
    {:ok, initial}
  end

  def start do
    GenServer.start(__MODULE__, %State{}, name: @name)
  end

  # Client interface functions
  def create_pledge(name, amount) do
    GenServer.call @name, {:create_pledge, name, amount}
  end

  def recent_pledges do
    GenServer.call @name, :recent_pledges
  end

  def total_pledged do
    GenServer.call @name, :total_pledged
  end

  def clear do
    GenServer.cast @name, :clear
  end

  # Handle calls
  def handle_call(:recent_pledges, _from, state), do: {:reply, state.pledges, state}
  def handle_call(:total_pledged, _from, state), do: {:reply, state.total, state}

  def handle_call({:create_pledge, name, amount}, _from, state) do
    {:ok, id}  = send_pledge_to_service(name, amount)

    new_pledges = [ {id, name, amount} | state.pledges ] |> Enum.take(state.num_pledges)
    new_total = state.total + amount
    new_state = %{ state | pledges: new_pledges, total: new_total}

    {:reply, id, new_state}
  end

  defp send_pledge_to_service(_name, _amount) do
    # CODE TO SEND PLEDGE TO EXTERNAL SERVICE PENDING
    Process.sleep(100)
    {:ok, "pledge-#{:rand.uniform(10_000)}"}
  end

  def handle_cast(:clear, _state) do
    {:noreply, %{pledges: [], total: 0}}
  end

end

