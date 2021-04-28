defmodule Servy.FourOhFourCounter do
  require Logger
  use GenServer

  @name __MODULE__

  def init(initial) do
    {:ok, initial}
  end

  def start do
    GenServer.start(__MODULE__, %{}, name: @name)
  end

  def init_count do
    GenServer.cast(@name, :init_count)
  end

  def bump_count(path) do
    GenServer.cast(@name, {:bump_count, path})
  end

  def get_count(path) do
    GenServer.call(@name, {:get_count, path})
  end

  def get_counts do
    GenServer.call(@name, :get_counts)
  end

  # Callbacks logic
  def handle_cast(:init_count, _state), do: {:noreply, %{}}
  def handle_cast({:bump_count, path}, state), do: {:noreply, Map.update(state, path, 1, &(&1 + 1))}

  def handle_call({:get_count, path}, _from, state), do: {:reply, Map.get(state, path, 0), state}
  def handle_call(:get_counts, _from, state), do: {:reply, state, state}

end

