defmodule Servy.SensorServer do
  use GenServer
  require Logger

  @name __MODULE__
  @refresh_period :timer.seconds(30)

  defmodule State do
    defstruct data: %{}, ts: 0, randomized: true
  end

  # Client interface

  def start_link(_arg, randomized \\ true) do
    Logger.info("Starting SensorServer...")

    unless Application.fetch_env!(:servy, :env) == :test do
      GenServer.start_link(__MODULE__, randomized, name: @name)
    else
      GenServer.start_link(__MODULE__, false, name: @name)
    end
  end

  def get_sensor_data do
    GenServer.call(@name, :get_sensor_data)
  end

  # Server callbacks

  def init(randomized) do
    initial_state = run_tasks_to_get_sensor_data(randomized)
    Process.send_after(@name, :refresh_sensors, @refresh_period)
    {:ok, %State{data: initial_state, ts: DateTime.utc_now(), randomized: randomized}}
  end

  def handle_call(:get_sensor_data, _from, %State{} = state) do
    {:reply, state.data, state}
  end

  def handle_info(:refresh_sensors, %State{} = state) do
    initial_state = run_tasks_to_get_sensor_data(state.randomized)
    Process.send_after(@name, :refresh_sensors, @refresh_period)
    {:noreply, %State{data: initial_state, ts: DateTime.utc_now()}}
  end

  def handle_info(message, state) do
    # Log and Ignore direct messages
    Logger.warn("An unkwon message has arrived: #{inspect(message)}")
    {:noreply, state}
  end

  # Internal server logic

  defp run_tasks_to_get_sensor_data(randomized) do
    # Launch the three snapshots each in their own process
    sensors =
      [
        fn -> Servy.VideoCam.get_snapshot("cam-1", randomized) end,
        fn -> Servy.VideoCam.get_snapshot("cam-2", randomized) end,
        fn -> Servy.VideoCam.get_snapshot("cam-3", randomized) end,
        fn -> Servy.Tracker.get_location("bigfoot") end
      ]
      |> Enum.map(&Task.async/1)
      |> Enum.map(&Task.await/1)

    %{snapshots: Enum.take(sensors, 3), location: List.last(sensors)}
  end
end
