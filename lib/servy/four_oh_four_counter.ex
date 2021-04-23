defmodule Servy.FourOhFourCounter do

  require Logger

  alias Servy.GenericServer

  @name __MODULE__

  # Client interface
  def start(initial \\ %{}) when is_map(initial) do
    case Process.whereis(@name) do
      nil -> GenericServer.start(__MODULE__, initial, @name)
      pid -> pid
    end
  end

  def init_count(initial \\ %{}) when is_map(initial) do
    GenericServer.cast(@name, {:init_count, initial})
  end

  def bump_count(path) do
    GenericServer.cast(@name, {:bump_count, path})
  end

  def get_count(path) do
    GenericServer.call(@name, {:get_count, path})
  end

  def get_counts do
    GenericServer.call(@name, :get_counts)
  end

  # Callbacks logic
  def handle_cast({:init_count, new_state}, _state), do: new_state
  def handle_cast({:bump_count, path}, state), do: Map.update(state, path, 1, &(&1 + 1))

  def handle_call({:get_count, path}, state), do: {Map.get(state, path, 0), state}
  def handle_call(:get_counts, state), do: {state, state}

end

