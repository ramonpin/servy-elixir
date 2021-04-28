defmodule Servy.SensorServer do
  use GenServer

  @name __MODULE__

  defmodule State do
    defstruct data: %{}, randomized: true
  end

  # Client interface

  def start(random: randomized) do
    GenServer.start(__MODULE__, randomized, name: @name)
  end

  def get_sensor_data do
    GenServer.call @name, :get_sensor_data
  end

  # Server callbacks

  def init(randomized) do
    initial_state = run_tasks_to_get_sensor_data(randomized)
    {:ok, %State{data: initial_state, randomized: randomized}}
  end

  def handle_call(:get_sensor_data, _from, %State{} = state) do
    {:reply, state.data, state}
  end

  # Internal server logic

  defp run_tasks_to_get_sensor_data(randomized) do
    # Launch the three snapshots each in their own process
    sensors = [
      fn -> Servy.VideoCam.get_snapshot("cam-1", randomized) end,
      fn -> Servy.VideoCam.get_snapshot("cam-2", randomized) end,
      fn -> Servy.VideoCam.get_snapshot("cam-3", randomized) end,
      fn -> Servy.Tracker.get_location("bigfoot") end,
    ] |> Enum.map(&Task.async/1) |> Enum.map(&Task.await/1)

    %{snapshots: Enum.take(sensors, 3), location: List.last(sensors)}
  end
end

