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
    call @name, {:create_pledge, name, amount}
  end

  def recent_pledges do
    call @name, :recent_pledges
  end

  def total_pledged do
    call @name, :total_pledged
  end

  def clear do
    cast @name, :clear
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

  # Generic Server Logic
  def call(pid, message) do
    send pid, {:call, self(), message}
    receive do {:response, response} -> response end
  end

  def cast(pid, message) do
    send pid, {:cast, message}
  end

  def listen_loop(state) do
    receive do
      {:call, sender, message} when is_pid(sender) ->
        {response, new_state} = handle_call(message, state)
        send sender, {:response, response}
        listen_loop(new_state)
      {:cast, message} ->
        new_state = handle_cast(message, state)
        listen_loop(new_state)
      unexpected ->
        Logger.warn("Unexpected message on #{__MODULE__}: #{inspect unexpected}")
        listen_loop(state)
    end
  end

end

