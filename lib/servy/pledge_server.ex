defmodule Servy.PledgeServer do
  use GenServer
  require Logger

  @name __MODULE__

  defmodule State do
    defstruct num_pledges: 3, pledges: [], total: 0
  end

  def start_link(_arg) do
    Logger.info "Starting PledgeServer..."
    GenServer.start_link(__MODULE__, %State{}, name: @name)
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

  def set_cache_size(n) when is_integer(n) do
    GenServer.cast @name, {:set_cache_size, n}
  end

  # GENSERVER CALLBACKS
  # ----------------------
  def init(args) do
    case Mix.env do
      :test ->
        # We do not want to retrieve recent pledges from
        # external server while in test
        {:ok, args}

      _env ->
      recent_pledges = fetch_recent_pledges_from_service()
      total = Enum.reduce(recent_pledges, 0, fn {_, _, amnt}, total -> total + amnt end)
      {:ok, %{ args | pledges: recent_pledges, total: total}}
    end
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

  # Handle casts
  def handle_cast(:clear, _state) do
    {:noreply, %State{}}
  end

  def handle_cast({:set_cache_size, n}, state) do
    {:noreply, %{ state | num_pledges: n, pledges: Enum.take(state.pledges, n) }}
  end

  # Handle info messages
  def handle_info(message, state) do
    # Log and Ignore direct messages
    Logger.warn("An unkwon message has arrived: #{inspect message}")
    {:noreply, state}
  end

  # Internal service logic
  defp send_pledge_to_service(_name, _amount) do
    # CODE TO SEND PLEDGE TO EXTERNAL SERVICE PENDING
    Process.sleep(100)
    {:ok, "pledge-#{:rand.uniform(10_000)}"}
  end

  defp fetch_recent_pledges_from_service() do
    # CODE TO SIMULATE RETRIEVAL OF LAST PLEDGES
    Process.sleep(100)
    [{"fake-0000", "wilma", 10}, {"fake-0001", "robert", 15}]
  end

end

