defmodule Servy.PledgeServer do

  @name :pledge_server

  def start do
    pid = spawn(__MODULE__, :listen_loop, [[]])
    Process.register(pid, @name)
    pid
  end

  def listen_loop(state) do
    receive do
      {sender, :create_pledge, name, amount} ->
        {:ok, id}  = send_pledge_to_service(name, amount)
        send sender, {:response, id}
        listen_loop([ {id, name, amount} | state ] |> Enum.take(3))

      {sender, :recent_pledges} ->
        send sender, {:response, state}
        listen_loop(state)
    end

  end

  def create_pledge(name, amount) do
    send @name, {self(), :create_pledge, name, amount}

    receive do {:response, id} -> id end
  end

  def recent_pledges do
    send @name, {self(), :recent_pledges}

    receive do {:response, pledges} -> pledges end
  end

  defp send_pledge_to_service(_name, _amount) do
    # CODE TO SEND PLEDGE TO EXTERNAL SERVICE PENDING
    Process.sleep(100)
    {:ok, "pledge-#{:rand.uniform(10_000)}"}
  end

end

