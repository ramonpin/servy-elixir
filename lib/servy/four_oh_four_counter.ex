defmodule Servy.FourOhFourCounter do

  require Logger

  @name __MODULE__

  # Client interface
  def start(initial \\ %{}) when is_map(initial) do
    case Process.whereis(__MODULE__) do
      nil ->
        pid = spawn(__MODULE__, :listen_loop, [initial])
        Process.register(pid, @name)
        pid
      pid ->
        pid
    end
  end

  def init_count(initial \\ %{}) when is_map(initial) do
    send @name, {self(), :init_count, initial}
  end

  def bump_count(path) do
    send @name, {self(), :bump_count, path}
  end

  def get_count(path) do
    send @name, {self(), :get_count, path}

    receive do {:result, count} -> count end
  end

  def get_counts do
    send @name, {self(), :get_counts}

    receive do {:result, counts} -> counts end
  end

  # Server logic
  def listen_loop(state) do
    receive do
      {_sender, :init_count, state} ->
        listen_loop(state)

      {_sender, :bump_count, path} ->
        listen_loop(Map.update(state, path, 1, &(&1 + 1)))

      {sender, :get_count, path} ->
        send sender, {:result, Map.get(state, path, 0)}
        listen_loop(state)

      {sender, :get_counts} ->
        send sender, {:result, state}
        listen_loop(state)

      unexpected ->
        Logger.warn("Unexpected message on #{__MODULE__}: #{inspect unexpected}")
    end
  end

end

