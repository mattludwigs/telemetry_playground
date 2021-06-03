defmodule TelemetryPlayground.Aggregator do
  @moduledoc """
  Example Aggregator service

  This is not complete generic but is mostly done to repersent what type of work
  might have to be done here.
  """

  use GenServer

  alias Telemetry.Metrics.{Counter, LastValue}

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def report_metric(metric, measurement, tags) do
    GenServer.call(__MODULE__, {:metric, metric, measurement, tags})
  end

  def last_value() do
    GenServer.call(__MODULE__, :last_value)
  end

  def count() do
    GenServer.call(__MODULE__, :count)
  end

  def count(tag) do
    GenServer.call(__MODULE__, {:count, tag})
  end

  @impl GenServer
  def init(_args) do
    {:ok, %{counters: %{}, last_value: nil}}
  end

  @impl GenServer
  def handle_call({:metric, %Counter{}, _measurement, tags}, _from, state) do
    # Hardcoding things but can be made more generic
    new_counters = Map.update(state.counters, tags.state, 1, fn n -> n + 1 end)
    {:reply, :ok, %{state | counters: new_counters}}
  end

  def handle_call({:metric, %LastValue{}, measurement, _tags}, _from, state) do
    {:reply, :ok, %{state | last_value: measurement}}
  end

  def handle_call({:count, tag}, _from, state) do
    count = Map.get(state.counters, tag, 0)

    IO.puts("""
    #{inspect(tag)}\t#{inspect(count)}
    """)

    {:reply, :ok, state}
  end

  def handle_call(:count, _from, state) do
    for {tag, count} <- state.counters do
      IO.puts("#{inspect(tag)}\t#{inspect(count)}")
    end

    {:reply, :ok, state}
  end

  def handle_call(:last_value, _from, state) do
    {:reply, state.last_value, state}
  end
end
