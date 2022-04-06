defmodule Servy.SensorServer do

  @name :sensor_server

  use GenServer

  defmodule State do
    defstruct state: %{}, refresh_interval: :timer.seconds(60)
  end

  # Client Interface

  def start do
    GenServer.start(__MODULE__, %State{}, name: @name)
  end

  def get_sensor_data do
    GenServer.call @name, :get_sensor_data
  end

  def set_refresh_interval(time) do
    GenServer.cast @name, {:set_refresh_interval, time}
  end


  # Server Callbacks

  def init(%State{refresh_interval: interval} = state) do
    initial_state = run_tasks_to_get_sensor_data()
    schedule_refresh(interval)
    {:ok, %State{state | state: initial_state}}
  end

  def handle_info(:refresh, %State{refresh_interval: interval} = state) do
    IO.puts "Refreshing the cache...."
    new_state = run_tasks_to_get_sensor_data()
    schedule_refresh(interval)
    {:noreply, %State{state | state: new_state}}
  end

  def handle_info(unexpected, state) do
    IO.puts "Can't touch this! #{inspect unexpected}"
    {:noreply, state}
  end

  defp schedule_refresh(interval) do
    Process.send_after(self(), :refresh, interval)
  end

  def handle_call(:get_sensor_data, _from, %State{state: current_state} = state) do
    {:reply, current_state, state}
  end

  def handle_cast({:set_refresh_interval, interval}, state) do
    IO.puts "Setting new interval.. #{interval}ms"
    {:noreply, %State{state | refresh_interval: interval}}
  end


  defp run_tasks_to_get_sensor_data do
    IO.puts "Running tasks to get sensor data..."

    task = Task.async(fn -> Servy.Tracker.get_location("bigfoot") end)

    snapshots =
      ["cam-1", "cam-2", "cam-3"]
      |> Enum.map(&Task.async(fn -> Servy.Api.VideoCam.get_snapshot(&1) end))
      |> Enum.map(&Task.await/1)

    where_is_bigfoot = Task.await(task)

    %{snapshots: snapshots, location: where_is_bigfoot}
  end
end
