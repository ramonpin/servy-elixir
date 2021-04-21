defmodule Servy.PledgeServer do

  require Logger

  @name __MODULE__
  @num_pledges 3

  # Client interface functions
  def start(initial \\ %{pledges: [], total: 0}) do
    pid = spawn(__MODULE__, :listen_loop, [initial])
    Process.register(pid, @name)
    pid
  end

  def create_pledge(name, amount) do
    send @name, {self(), :create_pledge, name, amount}

    receive do {:response, id} -> id end
  end

  def recent_pledges do
    send @name, {self(), :recent_pledges}

    receive do {:response, pledges} -> pledges end
  end

  def total_pledged do
    send @name, {self(), :total_pledged}

    receive do {:response, total} -> total end
  end

  # Server logic
  def listen_loop(state) do
    receive do
      {sender, :create_pledge, name, amount} ->
        {:ok, id}  = send_pledge_to_service(name, amount)
        send sender, {:response, id}
        new_pledges = [ {id, name, amount} | state.pledges ] |> Enum.take(@num_pledges)
        new_total = state.total + amount
        listen_loop(%{ state | pledges: new_pledges, total: new_total})

      {sender, :recent_pledges} ->
        send sender, {:response, state.pledges}
        listen_loop(state)

      {sender, :total_pledged} ->
        send sender, {:response, state.total}
        listen_loop(state)

      unexpected ->
        Logger.warn("Unexpected message on #{__MODULE__}: #{inspect unexpected}")
        listen_loop(state)
    end

  end

  defp send_pledge_to_service(_name, _amount) do
    # CODE TO SEND PLEDGE TO EXTERNAL SERVICE PENDING
    Process.sleep(100)
    {:ok, "pledge-#{:rand.uniform(10_000)}"}
  end

end

