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

  @doc """
  Dump the metric log
  """
  def dump() do
    GenServer.call(__MODULE__, :dump)
  end

  @impl GenServer
  def init(_args) do
    # 250 is just the first number that poped into my head
    # also not sure that the buffer should live in the aggregator but this
    # is only for example purposes only.
    # this buffer as very little strucuture and can be improved to better handle
    # the different supported metric types.
    buffer = CircularBuffer.new(250)
    {:ok, %{counters: %{}, last_value: nil, buffer: buffer}}
  end

  @impl GenServer
  def handle_call({:metric, %Counter{}, _measurement, tags} = metric, _from, state) do
    # Hardcoding things but can be made more generic
    new_counters = Map.update(state.counters, tags.state, 1, fn n -> n + 1 end)
    buffer = CircularBuffer.insert(state.buffer, metric)
    {:reply, :ok, %{state | counters: new_counters, buffer: buffer}}
  end

  def handle_call({:metric, %LastValue{}, measurement, _tags} = metric, _from, state) do
    buffer = CircularBuffer.insert(state.buffer, metric)
    {:reply, :ok, %{state | last_value: measurement, buffer: buffer}}
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

  def handle_call(:dump, _from, state) do
    {:reply, CircularBuffer.to_list(state.buffer), state}
  end

  def handle_call(:last_value, _from, state) do
    {:reply, state.last_value, state}
  end
end
