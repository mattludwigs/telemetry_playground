defmodule TelemetryMetricsETS.Buffer do
  use GenServer

  alias Telemetry.Metrics

  @doc """
  Start the buffer
  """
  @spec start_link(keyword()) :: GenServer.on_start()
  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  @spec insert_metrics([Metrics.t()]) :: :ok
  def insert_metrics(metrics) do
    GenServer.call(__MODULE__, {:insert_metrics, metrics})
  end

  def to_list() do
    GenServer.call(__MODULE__, :to_list)
  end

  @impl GenServer
  def init(args) do
    buffer_size = Keyword.get(args, :buffer_size, 250)

    buffer = CircularBuffer.new(buffer_size)

    {:ok, %{buffer: buffer}}
  end

  @impl GenServer
  def handle_call({:insert_metrics, data}, _from, state) do
    timestamp = DateTime.utc_now()
    new_buffer = CircularBuffer.insert(state.buffer, {timestamp, data})

    {:reply, :ok, %{state | buffer: new_buffer}}
  end

  def handle_call(:to_list, _from, state) do
    {:reply, CircularBuffer.to_list(state.buffer), state}
  end
end
